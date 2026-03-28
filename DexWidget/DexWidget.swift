import WidgetKit
import SwiftUI
import SwiftData
import UIKit

@MainActor
struct Provider: TimelineProvider {
    var sharedModelContainer: ModelContainer = {
        do {
            return try SharedModelContainer.make()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Task {
            let entry = await currentEntry() ?? .placeholder
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let entry = await currentEntry() ?? .placeholder
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }

    private func currentEntry() async -> SimpleEntry? {
        guard let results = try? sharedModelContainer.mainContext.fetch(FetchDescriptor<Pokemon>()),
              let entryPokemon = results.randomElement() else {
            return nil
        }

        // Widgets should render local entry data, not depend on live AsyncImage loading.
        let spriteData = await fetchSpriteData(from: entryPokemon.spriteURL)

        return SimpleEntry(
            date: .now,
            name: entryPokemon.name,
            types: entryPokemon.types,
            spriteData: spriteData
        )
    }

    private func fetchSpriteData(from url: URL) async -> Data? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return nil
            }
            return data
        } catch {
            return nil
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let types: [String]
    let spriteData: Data?
    
    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "mew",
            types: ["psychic"],
            spriteData: nil
        )
    }
}

struct DexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    var entry: Provider.Entry
    
    var pokemonImage: some View {
        Group {
            if let data = entry.spriteData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
            } else {
                Image(.mew)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
            }
        }
    }
    
    var typesView: some View {
        ForEach(entry.types, id: \.self) {
            type in
            Text(type.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(Color(type.capitalized))
                .clipShape(.capsule)
                .shadow(radius: 3)
        }
    }

    var body: some View {
        switch widgetSize {
        case .systemMedium:
            HStack {
                pokemonImage
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.title)
                        .padding(.vertical, 1)
                    
                    HStack {
                        typesView
                    }
                }
                .layoutPriority(1)
                
                Spacer()
            }
        case .systemLarge:
            ZStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        typesView
                    }
                }
            }
        default:
            pokemonImage
        }
    }
}

struct DexWidget: Widget {
    let kind: String = "DexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DexWidgetEntryView(entry: entry)
                .foregroundStyle(.black)
                .containerBackground(Color(entry.types.first?.capitalized ?? "Normal"), for: .widget)
        }
        .configurationDisplayName("Pokémon")
        .description("See a random Pokémon.")
    }
}

#Preview(as: .systemSmall) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
}

#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
}

#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
}
