import SwiftUI

struct ExpandableView<T: ExpandableItem>: View {
    @State private var isExpanded = false
    let item: T
    
    var body: some View {
        DisclosureGroup(
            content: {
                ForEach(item.expandables, id: \.name) { expandable in
                    expandable.link()
                }.tint(.indigo)
            }) {
                item.link().tint(Asset.primary.swiftUIColor)
            }
            .tint(item.expandables.isEmpty ? .clear : Asset.primary.swiftUIColor)
            .eraseToAnyView()
    }
    
#if DEBUG
    @ObservedObject var iO = injectionObserver
#endif
}

protocol ExpandableItem: Identifiable {
    var name: String { get }
    associatedtype Object: Hashable
    associatedtype Expandable: ExpandableItem
    typealias Destination = Never
    var expandables: [Expandable] { get }
    
    func link() -> CustomizedNavigationLink<Object>
}

extension WorkoutsFeature.Path.State: ExpandableItem {
    func link() -> CustomizedNavigationLink<WorkoutsFeature.Path.State> {
        CustomizedNavigationLink(value: self, label: name, hasArrow: false)
    }
    
    typealias Object = WorkoutsFeature.Path.State
    
    var expandables: [Exercise] {
        []
    }
}

extension Workout: ExpandableItem {
    func link() -> CustomizedNavigationLink<Workout> {
        CustomizedNavigationLink(value: self, label: name, hasArrow: false)
    }
    
    typealias Object = Workout
    
    var expandables: [Exercise] {
        exercises.sorted{ $0.name < $1.name }
    }
}

extension Exercise: ExpandableItem {
    var expandables: [Workout] {
        workouts.sorted{ $0.name < $1.name }
    }
    
    private var tagsString: String {
        ListFormatter.localizedString(byJoining: tags.map { $0.name })
    }
    
    func link() -> CustomizedNavigationLink<Exercise> {
        CustomizedNavigationLink(value: self, label: name)
    }
}
