import Zenith
import ZenithCoreInterface
import SwiftUI
import SwiftData
import SFSafeSymbols

@Model
final class CommingSoon {
    var title: String
    var items: [String]
    
    init(title: String, items: [String]) {
        self.title = title
        self.items = items
    }
}

// Conformidade manual com Codable
extension CommingSoon: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case items
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(items, forKey: .items)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let title = try container.decode(String.self, forKey: .title)
        let items = try container.decode([String].self, forKey: .items)
        self.init(title: title, items: items)
    }
}

extension String {
    func toObject<T: Decodable>() -> T? {
        if let jsonData = data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: jsonData)
            } catch {
                print("Erro ao decodificar JSON: \(error)")
                return nil
            }
        }
        return nil
    }
}

extension Encodable {
    func json() -> String? {
        do {
            let jsonData = try JSONEncoder().encode(self)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}

struct CommingSoonView: View, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator: any ThemeConfiguratorProtocol
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CommingSoon]
    @State var filteredItems: [CommingSoon] = []
    @State var sectionText: String = String()
    @State var featureText: String = String()
    @State var dynamicText: String = String()
    @State var isDynamicText = false
    @State private var showPopover = false
    @Environment(ToastModel.self) var toast
    
    var body: some View {
        NavigationStack {
            PrincipalToolbarView.start("Comming Soon") {
                Form {
                    Toggle("Habilitar Text Dinamico", isOn: $isDynamicText)
                        .toggleStyle(.default(.highlightA))
                        .foregroundStyle(colors.contentA)
                        .listRowBackground(colors.backgroundB)
                    if isDynamicText {
                        TextField("Texto Dinamico", text: $dynamicText)
                            .onSubmit {
                                addDynamicItem()
                            }
                            .foregroundStyle(colors.contentA)
                            .listRowBackground(colors.backgroundB)
                    } else {
                        TextField("Nome da Sessão", text: $sectionText)
                            .onChange(of: sectionText) {
                                self.applyFilter(with: sectionText)
                            }
                            .onSubmit {
                                addItem()
                            }
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {
                                        self.showPopover = items.isNotEmpty
                                    }
                            )
                            .popover(
                                isPresented: $showPopover,
                                attachmentAnchor: .point(
                                    .top
                                )
                            ) {
                                ChipGridView(chips: .constant((filteredItems.isEmpty ? items : filteredItems).map { $0.title })) { section in
                                    self.sectionText = section
                                    DispatchQueue.main.async {
                                        showPopover = false
                                    }
                                    hideKeyboard()
                                }
                                .padding()
                                .frame(minWidth: 50, minHeight: 80, maxHeight: 400)
                                .presentationCompactAdaptation(.popover)
                            }
                            .foregroundStyle(colors.contentA)
                            .listRowBackground(colors.backgroundB)
                        TextField("Nova Feature", text: $featureText)
                            .onSubmit {
                                addItem()
                            }
                            .foregroundStyle(colors.contentA)
                            .listRowBackground(colors.backgroundB)
                    }
                    
                    ForEach(items.indices, id: \.self) { sectionIndex in
                        if items.count > 0 {
                            Section(
                                header:
                                    Text(items[safe: sectionIndex]?.title ?? "")
                                    .font(fonts.largeBold)
                            ){
                                ForEach(items[safe: sectionIndex]?.items ?? [], id: \.self) { item in
                                    Text(item)
                                        .font(fonts.small)
                                        .foregroundStyle(colors.contentA)
                                }
                                .onDelete { sets in
                                    deleteItems(at: sets, in: sectionIndex)
                                }
                            }
                            .foregroundStyle(colors.contentA)
                            .listRowBackground(colors.backgroundB)
                        }
                    }
                    HStack {
                        Button(action: {
                            importData()
                        }) {
                            HStack {
                                Text("Importar")
                                    .textStyle(.small(.contentA))
                                Image(systemSymbol: .squareAndArrowDownOnSquareFill)
                                    .font(.callout)
                            }
                        }
                        .buttonStyle(.contentA())
                        Spacer()
                        Button(action: {
                            exportData()
                        }) {
                            HStack {
                                Text("Exportar")
                                    .textStyle(.small(.highlightA))
                                Image(systemSymbol: .squareAndArrowUpOnSquareFill)
                                    .font(.callout)
                            }
                        }
                        .buttonStyle(.highlightA())
                    }
                    .padding(.vertical, spacings.small)
                    .listRowBackground(colors.backgroundB)
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func importData() {
        guard let json = UIPasteboard.general.string, let commingSoons: [CommingSoon] = json.toObject() else {
            toast.showError(message: "Falha ao Importar os Dados")
            return
        }
        deleteAllCommingSoon()
        
        commingSoons.forEach { commingSoon in
            modelContext.insert(commingSoon)
        }
        do {
            try modelContext.save()
            toast.showInfo(message: "Dados Importados")
        } catch {
            print(error)
        }
        
    }
    
    private func exportData() {
        guard let json = items.json() else {
            toast.showError(message: "Falha ao Exportar os Dados")
            return
        }
        toast.showInfo(message: "Dados Exportados")
        UIPasteboard.general.string = json
    }
    
    private func applyFilter(with text: String) {
        if text.isEmpty {
            filteredItems = []
            showPopover = false
        } else {
            filteredItems = items.filter { $0.title.localizedCaseInsensitiveContains(text) }
            showPopover = filteredItems.count > 0
        }
    }
    
    private func addItem() {
        withAnimation {
            saveCommingSoon(title: sectionText, items: [featureText])
            sectionText = ""
            featureText = ""
        }
    }
    
    private func addDynamicItem() {
        withAnimation {
            var splittedText = dynamicText
                .split(
                    separator: ","
                )
            
            if dynamicText.contains("-") {
                splittedText = dynamicText.split(
                    separator: "-"
                )
            }
            
            var items = splittedText
                .map{
                    String(
                        $0
                    ).trimmingCharacters(
                        in: .whitespaces
                    )
                }
            let title = sectionText.isNotEmpty ? sectionText : items.removeFirst()
            saveCommingSoon(title: title, items: items)
            sectionText = ""
            dynamicText = ""
        }
    }
    
    private func saveCommingSoon(title: String, items: [String]) {
        if let commingSoon = fetchCommingSoon(title) {
            commingSoon.items.append(contentsOf: Set(items))
        } else {
            let newItem = CommingSoon(
                title: title,
                items: Array(Set(items))
            )
            modelContext
                .insert(
                    newItem
                )
        }
        try? modelContext.save()
    }
    
    private func fetchCommingSoons() -> [CommingSoon] {
        do {
            let result = try modelContext.fetch(FetchDescriptor<CommingSoon>())
            return result
        } catch {
            return []
        }
    }
    
    func deleteAllCommingSoon() {
        // Fetch all instances of CommingSoon
        let fetchDescriptor = FetchDescriptor<CommingSoon>()
        if let results = try? modelContext.fetch(fetchDescriptor) {
            for item in results {
                modelContext.delete(item)
            }
            do {
                try modelContext.save()
            } catch {
                print("Failed to save after deletion: \(error)")
            }
        } else {
            print("Failed to fetch items for deletion")
        }
    }
    
    private func fetchCommingSoon(_ title: String) -> CommingSoon? {
        
        let predicate = #Predicate<CommingSoon> { $0.title == title }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let result = try modelContext.fetch(descriptor)
            return result.first
        } catch {
            return nil
        }
    }
    
    private func deleteItems(at offsets: IndexSet, in sectionIndex: Int) {
        withAnimation {
            let section = items[sectionIndex]
            
            section.items.remove(atOffsets: offsets)
            if section.items.isEmpty {
                modelContext.delete(section)
            }
            
            try? modelContext.save()
        }
    }
    
}

