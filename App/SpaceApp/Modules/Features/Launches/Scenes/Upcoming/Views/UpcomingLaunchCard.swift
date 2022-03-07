import SwiftUI

struct UpcomingLaunchCard: View { // NextLaunchView
    struct Model: Equatable, Hashable, Identifiable {
        let id: String
        let imageURL: String
        let name: String
        let flightNumber: Int
        let date: String
        let details: String?
    }
    
    private let model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    RemoteImage(url: model.imageURL)
                        .dsFrameOfSize(.xLarge)
                    VStack(
                        alignment: .leading,
                        spacing: .dsSpacing(.micro)
                    ) {
                        Text(model.name)
                            .dsTypography(.headline, color: .primary)
                        Text(model.date)
                            .dsTypography(.body, color: .secondary)
                        Text("#\(model.flightNumber)")
                            .dsTypography(.body, color: .secondary)
                            .lineLimit(nil)
                    }
                    Spacer()
                }
                if let details = model.details {
                    Text(details)
                        .dsTypography(.body, color: .secondary)
                        .lineLimit(3)
                }
            }
            .padding(.all, .dsSpacing(.small))
            .background(Color.ds(.background))
            .dsCornerRadius(.small)
            .overlay(
                RoundedRectangle(cornerRadius: .dsCornerRadius(.small))
                    .stroke(
                        Color.ds(.background),
                        lineWidth: 1
                    )
            )
        }
    }
}

extension UpcomingLaunchCard.Model {
    init(_ launch: Launch) {
        self.init(
            id: launch.id,
            imageURL: launch.links.patch.small ?? "",
            name: launch.name,
            flightNumber: launch.flightNumber,
            date: launch.date.formatted(
                .dateTime
                .month(.wide)
                .day(.twoDigits)
                .year()
             ),
            details: launch.details
        )
    }
}

#if DEBUG
extension UpcomingLaunchCard.Model {
    static func fixture(
        id: String = "id",
        imageURL: String = "www.mock.com/image.jpg",
        name: String = "CRS-20",
        flightNumber: Int = 91,
        date: String = "July 03, 2020",
        details: String? = nil
    ) -> Self {
        .init(
            id: id,
            imageURL: imageURL,
            name: name,
            flightNumber: flightNumber,
            date: date,
            details: details
        )
    }
}

struct UpcomingLaunchCard_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingLaunchCard(
            model: .fixture(details: "Bla bla bla, bla bla bla bla bla bla bla bla. \nBla bla bla, bla bla bla bla bla bla bla bla. \nBla bla bla bla bla bla bla...")
        )
        .preferredColorScheme(.dark)
        
        UpcomingLaunchCard(
            model: .fixture(details: "Bla bla bla, bla bla bla bla bla bla bla bla. \nBla bla bla, bla bla bla bla bla bla bla bla. \nBla bla bla bla bla bla bla...")
        )
        .preferredColorScheme(.light)
    }
}
#endif
