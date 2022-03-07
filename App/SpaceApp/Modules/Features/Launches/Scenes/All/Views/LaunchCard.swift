import SwiftUI

struct LaunchCard: View {
    struct Model {
        let id: String
        let imageURL: String
        let flightNumber: Int
        let name: String
        let date: String
        let success: Bool
    }
    
    private let model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        HStack {
            RemoteImage(url: model.imageURL)
                .frame(
                    width: DS.Size.xLarge.width,
                    height: .infinity
                )
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("#\(model.flightNumber)")
                        .dsTypography(.body, color: .secondary)
                        .lineLimit(nil)
                }
                VStack(
                    alignment: .leading,
                    spacing: .dsSpacing(.micro)
                ) {
                    Text(model.name)
                        .dsTypography(.headline, color: .primary)
                    Text(model.date)
                        .dsTypography(.body, color: .secondary)
                    Text(model.success ? "Success" : "Failure")
                        .dsTypography(.body, color: .secondary)
                }
            }
            Spacer()
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

extension LaunchCard.Model {
    init(_ launch: Launch) {
        self.init(
            id: launch.id,
            imageURL: launch.links.patch.small ?? "",
            flightNumber: launch.flightNumber,
            name: launch.name,
            date: launch.date.formatted(
                .dateTime
                .month(.wide)
                .day(.twoDigits)
                .year()
             ),
            success: launch.success ?? false
        )
    }
}


#if DEBUG
extension LaunchCard.Model {
    static func fixture(
        id: String = "id",
        imageURL: String = "www.mock.com/image.jpg",
        flightNumber: Int = 91,
        name: String = "CRS-20",
        date: String = "July 03, 2020",
        success: Bool = true
    ) -> Self {
        .init(
            id: id,
            imageURL: imageURL,
            flightNumber: flightNumber, name: name,
            date: date,
            success: success
        )
    }
}

struct LaunchCard_Previews: PreviewProvider {
    static var previews: some View {
        LaunchCard(
            model: .fixture()
        )
        .preferredColorScheme(.dark)
        
        LaunchCard(
            model: .fixture()
        )
        .preferredColorScheme(.light)
    }
}
#endif
