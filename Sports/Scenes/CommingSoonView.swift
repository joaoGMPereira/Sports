import SwiftUI
import SwiftData

@Model
final class CommingSoon {
    var title: String
    var items: [String]
    
    init(title: String, items: [String]) {
        self.title = title
        self.items = items
    }
}

struct CommingSoonView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [CommingSoon]
    @State var sectionText: String = String()
    @State var dynamicText: String = String()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome da Sessão", text: $sectionText)
                    .onSubmit {
                        addItem()
                    }
                TextField("Nova Feature", text: $dynamicText)
                    .onSubmit {
                        addItem()
                    }
                ForEach(items.indices, id: \.self) { sectionIndex in
                    if items.count > 0 {
                        Section(items[sectionIndex].title) {
                            ForEach(items[sectionIndex].items, id: \.self) { item in
                                Text(item)
                            }
                            .onDelete { sets in
                                deleteItems(at: sets, in: sectionIndex)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
            .navigationTitle("Comming Soon")
        }
    }
    
    private func addItem() {
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
            
            var texts = splittedText
                .map{
                    String(
                        $0
                    ).trimmingCharacters(
                        in: .whitespaces
                    )
                }
            let title = sectionText.isNotEmpty ? sectionText : texts.removeFirst()
            let newItem = CommingSoon(
                title: title,
                items: Array(Set(texts))
            )
            modelContext
                .insert(
                    newItem
                )
            try? modelContext.save()
            sectionText = ""
            dynamicText = ""
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

