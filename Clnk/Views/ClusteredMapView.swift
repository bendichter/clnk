import SwiftUI
import MapKit

// MARK: - Restaurant Annotation
class RestaurantAnnotation: NSObject, MKAnnotation {
    let restaurant: Restaurant
    
    var coordinate: CLLocationCoordinate2D {
        restaurant.locationCoordinate
    }
    
    var title: String? {
        restaurant.name
    }
    
    var subtitle: String? {
        "\(restaurant.cuisine.emoji) \(restaurant.cuisine.rawValue)"
    }
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        super.init()
    }
}

// MARK: - Clustered Map View (UIViewRepresentable)
struct ClusteredMapView: UIViewRepresentable {
    let restaurants: [Restaurant]
    let userLocation: CLLocation?
    let searchLocation: CLLocation?
    let searchRadius: Double
    @Binding var selectedRestaurant: Restaurant?
    var onRegionChanged: ((MKCoordinateRegion) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        
        // Register annotation views
        mapView.register(
            RestaurantAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier
        )
        mapView.register(
            RestaurantClusterAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier
        )
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update annotations
        let currentAnnotations = mapView.annotations.compactMap { $0 as? RestaurantAnnotation }
        let currentRestaurantIds = Set(currentAnnotations.map { $0.restaurant.id })
        let newRestaurantIds = Set(restaurants.map { $0.id })
        
        // Remove old annotations
        let toRemove = currentAnnotations.filter { !newRestaurantIds.contains($0.restaurant.id) }
        mapView.removeAnnotations(toRemove)
        
        // Add new annotations
        let toAdd = restaurants.filter { !currentRestaurantIds.contains($0.id) }
            .map { RestaurantAnnotation(restaurant: $0) }
        mapView.addAnnotations(toAdd)
        
        // Update region if needed (only on first load or significant change)
        if context.coordinator.shouldUpdateRegion {
            if let location = searchLocation ?? userLocation {
                let span = spanForRadius(searchRadius)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.setRegion(region, animated: true)
            }
            context.coordinator.shouldUpdateRegion = false
        }
        
        // Update selection
        if let selected = selectedRestaurant {
            if let annotation = mapView.annotations
                .compactMap({ $0 as? RestaurantAnnotation })
                .first(where: { $0.restaurant.id == selected.id }) {
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func spanForRadius(_ radiusMiles: Double) -> MKCoordinateSpan {
        let latDelta = radiusMiles / 69.0 * 2.5
        let lonDelta = radiusMiles / 54.6 * 2.5
        return MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    }
    
    // MARK: - Coordinator
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ClusteredMapView
        var shouldUpdateRegion = true
        
        init(_ parent: ClusteredMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't customize user location
            if annotation is MKUserLocation {
                return nil
            }
            
            // Handle clusters
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier,
                    for: annotation
                ) as? RestaurantClusterAnnotationView
                view?.configure(with: cluster)
                return view
            }
            
            // Handle restaurant annotations
            if let restaurantAnnotation = annotation as? RestaurantAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier,
                    for: annotation
                ) as? RestaurantAnnotationView
                view?.configure(with: restaurantAnnotation)
                return view
            }
            
            return nil
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if let restaurantAnnotation = annotation as? RestaurantAnnotation {
                parent.selectedRestaurant = restaurantAnnotation.restaurant
            } else if let cluster = annotation as? MKClusterAnnotation {
                // Zoom into cluster
                let annotations = cluster.memberAnnotations
                mapView.showAnnotations(annotations, animated: true)
            }
        }
        
        func mapView(_ mapView: MKMapView, didDeselect annotation: MKAnnotation) {
            if annotation is RestaurantAnnotation {
                // Small delay to allow for new selection
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if mapView.selectedAnnotations.isEmpty {
                        self.parent.selectedRestaurant = nil
                    }
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.onRegionChanged?(mapView.region)
        }
    }
}

// MARK: - Restaurant Annotation View
class RestaurantAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "RestaurantAnnotation"
    
    private let emojiLabel = UILabel()
    private let bubbleView = UIView()
    private let pinTail = UIImageView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Enable clustering
        clusteringIdentifier = "restaurant"
        
        // Bubble background
        bubbleView.backgroundColor = .white
        bubbleView.layer.cornerRadius = 20
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.2
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowRadius = 4
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        // Emoji label
        emojiLabel.font = .systemFont(ofSize: 20)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(emojiLabel)
        
        // Pin tail
        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)
        pinTail.image = UIImage(systemName: "triangle.fill", withConfiguration: config)
        pinTail.tintColor = .white
        pinTail.transform = CGAffineTransform(rotationAngle: .pi)
        pinTail.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pinTail)
        
        // Layout
        NSLayoutConstraint.activate([
            bubbleView.widthAnchor.constraint(equalToConstant: 40),
            bubbleView.heightAnchor.constraint(equalToConstant: 40),
            bubbleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bubbleView.topAnchor.constraint(equalTo: topAnchor),
            
            emojiLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            
            pinTail.centerXAnchor.constraint(equalTo: centerXAnchor),
            pinTail.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -3),
        ])
        
        // Set frame and center offset
        frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        centerOffset = CGPoint(x: 0, y: -25)
    }
    
    func configure(with annotation: RestaurantAnnotation) {
        emojiLabel.text = annotation.restaurant.imageEmoji
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let targetColor: UIColor = selected ? .systemOrange : .white
        let targetScale: CGFloat = selected ? 1.1 : 1.0
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.bubbleView.backgroundColor = targetColor
                self.pinTail.tintColor = targetColor
                self.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            }
        } else {
            bubbleView.backgroundColor = targetColor
            pinTail.tintColor = targetColor
            transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
        }
    }
}

// MARK: - Cluster Annotation View
class RestaurantClusterAnnotationView: MKAnnotationView {
    private let countLabel = UILabel()
    private let bubbleView = UIView()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Bubble background
        bubbleView.backgroundColor = .systemOrange
        bubbleView.layer.cornerRadius = 22
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOpacity = 0.25
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        bubbleView.layer.shadowRadius = 4
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleView)
        
        // Count label
        countLabel.font = .systemFont(ofSize: 16, weight: .bold)
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(countLabel)
        
        // Layout
        NSLayoutConstraint.activate([
            bubbleView.widthAnchor.constraint(equalToConstant: 44),
            bubbleView.heightAnchor.constraint(equalToConstant: 44),
            bubbleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bubbleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            countLabel.centerXAnchor.constraint(equalTo: bubbleView.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
        ])
        
        frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    }
    
    func configure(with cluster: MKClusterAnnotation) {
        let count = cluster.memberAnnotations.count
        countLabel.text = count > 99 ? "99+" : "\(count)"
        
        // Adjust size based on count
        let size: CGFloat = count > 50 ? 52 : (count > 20 ? 48 : 44)
        bubbleView.layer.cornerRadius = size / 2
        
        for constraint in bubbleView.constraints {
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.constant = size
            }
        }
    }
}
