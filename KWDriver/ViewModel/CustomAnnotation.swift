//
//  JobViewModal.swift
//  KWDriver
//
//  Created by Ramniwas Patidar on 21/12/23.
//

import Foundation
import MapKit


class CustomAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let customAnnotation = newValue as? CustomAnnotation else { return }
            markerTintColor = customAnnotation.markerTintColor
            glyphText = customAnnotation.glyphText
            if let image = customAnnotation.image {
                glyphImage = image
            }
        }
    }
}


class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var markerTintColor: UIColor
    var glyphText: String?
    var image: UIImage?

    init(
        coordinate: CLLocationCoordinate2D,
        title: String?,
        subtitle: String?,
        markerTintColor: UIColor,
        glyphText: String?,
        image: UIImage?
    ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.markerTintColor = markerTintColor
        self.glyphText = glyphText
        self.image = image
        super.init()
    }
}
