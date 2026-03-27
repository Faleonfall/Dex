import SwiftUI
import Charts

struct PokemonStatsView: View {
    var pokemon: Pokemon
    
    var body: some View {
        Chart(pokemon.stats) { stat in
            BarMark(
                x: .value("Value", stat.value),
                y: .value("Stat", stat.name)
            )
            .annotation(position: .trailing) {
                Text("\(stat.value)")
                    .padding(.top, -5)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .frame(height: 200)
        .padding([.leading, .bottom, .trailing])
        .foregroundStyle(Color(pokemon.types[0].capitalized))
        .chartXScale(domain: 0...pokemon.highestStat.value + 10)
    }
}

#Preview {
    PokemonStatsView(pokemon: PersistenceController.previewPokemon)
}
