import SwiftUI
import SFSafeSymbols

struct SystemSymbolPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedSymbol: String
    
    // Limita os símbolos para melhor performance
    var filteredSymbols: [SFSymbol] {
        Array(SFSymbol.allSymbols.prefix(100))
    }
    
    var body: some View {
            VStack {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 80, maximum: 100), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredSymbols, id: \.rawValue) { symbol in
                            symbolButton(symbol)
                        }
                    }
                    .padding()
                }
            }
    }
    
    @ViewBuilder
    private func symbolButton(_ symbol: SFSymbol) -> some View {
        VStack {
            Image(systemName: symbol.rawValue)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedSymbol == symbol.rawValue ? 
                              Color.accentColor.opacity(0.2) : 
                              Color.secondary.opacity(0.1))
                )
                .foregroundColor(selectedSymbol == symbol.rawValue ?
                                 Color.accentColor : Color.primary)
            
            Text(symbol.rawValue)
                .font(.system(size: 10))
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .frame(height: 80)
        .onTapGesture {
            selectedSymbol = symbol.rawValue
            dismiss()
        }
    }
}

#Preview {
    SystemSymbolPicker(
        selectedSymbol: .constant("star.fill")
    )
}
