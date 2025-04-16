import SwiftUI
import PopupView

extension EdgeInsets {
    init(
        top: CGFloat = 0,
        bottom: CGFloat = 0,
        leading: CGFloat = 0,
        trailing: CGFloat = 0
    ) {
        self.init(
            top: top,
            leading: leading,
            bottom: bottom,
            trailing: trailing
        )
    }
    
    init(
        vertical: CGFloat = 0,
        horizontal: CGFloat = 0
    ) {
        self.init(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

public extension View {
    
    @ViewBuilder
    func applyIf<T: View>(_ condition: Bool, apply: (Self) -> T) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func sheet(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> some View) -> some View {
        popup(isPresented: isPresented) {
            ActionSheetView {
                content()
            }
        } customize: {
            $0
                .type(.toast)
                .position(.bottom)
                .closeOnTap(false)
                .closeOnTapOutside(true)
                .isOpaque(true)
                .backgroundColor(.black.opacity(0.4))
        }
    }
    
    func gridSheet(
        model: Binding<GridSheetModel>,
        setPlanCreated: @escaping (String, String, String) -> Void,
        setPlanRemoved: @escaping (String) -> Void,
        setPlanSelected: @escaping (String) -> Void
    ) -> some View {
        sheet(isPresented: model.isPresented) {
            GridSetPlanSearchView(
                items: model.items,
                setPlanCreated: setPlanCreated,
                setPlanRemoved: setPlanRemoved,
                setPlanSelected: setPlanSelected
            )
        }
    }
    
    func gridSheet(
        title: String,
        model: Binding<GridSheetModel>,
        created: @escaping (String) -> Void,
        removed: @escaping (String) -> Void,
        selected: @escaping (String) -> Void
    ) -> some View {
        sheet(isPresented: model.isPresented) {
            GridSearchView(
                title: title,
                items: model.items,
                created: created,
                removed: removed,
                selected: selected
            )
        }
    }
    
    func createSerieSheet(isPresented: Binding<Bool>, completion: @escaping (String, String, String) -> Void) -> some View {
        sheet(isPresented: isPresented) {
            CreateSerieView(completion: completion)
        }
    }
    
    func createNameSheet(isPresented: Binding<Bool>, completion: @escaping (String) -> Void) -> some View {
        sheet(isPresented: isPresented) {
            CreateNameView(completion: completion)
        }
    }
}

struct GridSetPlanSearchView: View {
    @State private var search = String()
    @State var filteredItems: [String]
    @Binding var items: [String]
    @State private var setPlan: String = String()
    @State private var minRep: String = String()
    @State private var maxRep: String = String()
    @State private var keyboardHeight: CGFloat = 0
    @State private var enableSetPlan = false
    var setPlanSelected: (String) -> Void
    var setPlanRemoved: (String) -> Void
    var setPlanCreated: (String, String, String) -> Void
    
    init(
        items: Binding<[String]>,
        setPlanCreated: @escaping (String, String, String) -> Void,
        setPlanRemoved: @escaping (String) -> Void,
        setPlanSelected: @escaping (String) -> Void
    ) {
        self._filteredItems = State(initialValue: items.wrappedValue)
        self._items = items
        self.setPlanRemoved = setPlanRemoved
        self.setPlanSelected = setPlanSelected
        self.setPlanCreated = setPlanCreated
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar", text: $search)
                    .frame(height: 44)
                    .onChange(of: search) {
                        filteredItems = search.isEmpty ? items : items.filter({ $0.localizedLowercase.contains(search.localizedLowercase)})
                    }
                Spacer()
                DSBorderedButton(title: "Criar Serie") {
                    withAnimation {
                        enableSetPlan.toggle()
                    }
                }
            }
            ChipGridView(chips: $filteredItems, onRemove: setPlanRemoved, onClick: setPlanSelected)
                .onChange(of: items) {
                    withAnimation {
                        self.filteredItems = items
                    }
                }
        }
        .padding([.bottom, .horizontal])
        .safeAreaPadding(.bottom)
        .createSerieSheet(isPresented: $enableSetPlan) {
            self.enableSetPlan = false
            setPlanCreated($0 ,$1, $2)
        }
    }
    
    private func applyFilter(with text: String) {
        filteredItems = text.isEmpty ? items : items.filter { $0.localizedCaseInsensitiveContains(text) }
    }
}

struct GridSearchView: View {
    @State private var search = String()
    @State var filteredItems: [String]
    @Binding var items: [String]
    @State private var value: String = String()
    @State private var keyboardHeight: CGFloat = 0
    @State private var enableSetPlan = false
    let title: String
    var selected: (String) -> Void
    var removed: (String) -> Void
    var created: (String) -> Void
    
    init(
        title: String,
        items: Binding<[String]>,
        created: @escaping (String) -> Void,
        removed: @escaping (String) -> Void,
        selected: @escaping (String) -> Void
    ) {
        self.title = title
        self._filteredItems = State(initialValue: items.wrappedValue)
        self._items = items
        self.removed = removed
        self.selected = selected
        self.created = created
    }
    
    var body: some View {
        VStack {
            HStack {
                TextField("Buscar", text: $search)
                    .frame(height: 44)
                    .onChange(of: search) {
                        filteredItems = search.isEmpty ? items : items.filter({ $0.localizedLowercase.contains(search.localizedLowercase)})
                    }
                Spacer()
                DSBorderedButton(title: title) {
                    withAnimation {
                        enableSetPlan.toggle()
                    }
                }
            }
            ChipGridView(chips: $filteredItems, onRemove: removed, onClick: selected)
                .onChange(of: items) {
                    withAnimation {
                        self.filteredItems = items
                    }
                }
        }
        .padding([.bottom, .horizontal])
        .safeAreaPadding(.bottom)
        .createNameSheet(isPresented: $enableSetPlan) {
            self.enableSetPlan = false
            created($0)
        }
    }
    
    private func applyFilter(with text: String) {
        filteredItems = text.isEmpty ? items : items.filter { $0.localizedCaseInsensitiveContains(text) }
    }
}

struct CreateNameView: View {
    @State private var value: String = String()
    @State private var valueError = false
    var completion: (String) -> Void
    
    init(completion: @escaping (String) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        DSTextField(
            text: $value,
            placeholder: .constant(
                "Nome"
            ),
            showError: $valueError,
            errorText: .constant(
                "Preencha esse campo"
            )
        )
        .padding(
            EdgeInsets(
                horizontal: 20
            )
        )
        
        DSBorderedButton(title: "Criar", maxWidth: true) {
            if value.isNotEmpty {
                valueError = false
                completion(value)
            } else {
                withAnimation(Animation.easeInOut) {
                    valueError = value.isEmpty
                }
            }
        }
        .padding([.bottom, .horizontal])
        .safeAreaPadding(.bottom)
    }
}

struct CreateSerieView: View {
    @State private var setPlan: String = String()
    @State private var minRep: String = String()
    @State private var maxRep: String = String()
    @State private var setPlanError = false
    @State private var minRepError = false
    @State private var maxRepError = false
    var completion: (String, String, String) -> Void
    
    init(completion: @escaping (String, String, String) -> Void) {
        self.completion = completion
    }
    
    var body: some View {
        DSTextField(
            text: $setPlan,
            placeholder: .constant(
                "Series"
            ),
            showError: $setPlanError,
            errorText: .constant(
                "Preencha esse campo"
            )
        )
        .padding(
            EdgeInsets(
                horizontal: 20
            )
        )
        DSTextField(
            text: $minRep,
            placeholder: .constant(
                "Repetições Minimas"
            ),
            showError: $minRepError,
            errorText: .constant(
                "Preencha esse campo"
            )
        )
        .padding(
            EdgeInsets(
                horizontal: 20
            )
        )
        DSTextField(
            text: $maxRep,
            placeholder: .constant(
                "Repetições Máximas"
            ),
            showError: $maxRepError,
            errorText: .constant(
                "Preencha esse campo"
            )
        )
        .padding(
            EdgeInsets(
                horizontal: 20
            )
        )
        DSBorderedButton(title: "Criar", maxWidth: true) {
            if setPlan.isNotEmpty, minRep.isNotEmpty, maxRep.isNotEmpty {
                setPlanError = false
                minRepError = false
                maxRepError = false
                completion(setPlan, minRep, maxRep)
            } else {
                withAnimation(Animation.easeInOut) {
                    setPlanError = setPlan.isEmpty
                    minRepError = minRep.isEmpty
                    maxRepError = maxRep.isEmpty
                }
            }
        }
        .padding([.bottom, .horizontal])
        .safeAreaPadding(.bottom)
    }
}

struct DSTextField: View {
    @Binding var text: String
    @Binding var placeholder: String
    @Binding var showError: Bool
    @Binding var errorText: String
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .listRowSeparator(.hidden)
        HStack {
            Text(showError ? errorText : "")
                .font(.footnote)
                .foregroundStyle(Color.red)
            Spacer()
        }
    }
}


struct KeyboardProvider: ViewModifier {
    var keyboardHeight: Binding<CGFloat>
    var onKeyboardHide: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                guard let userInfo = notification.userInfo,
                      let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                self.keyboardHeight.wrappedValue = keyboardRect.height
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                self.keyboardHeight.wrappedValue = 0
                self.onKeyboardHide?() // Executa o completion quando o teclado for escondido
            }
    }
}

public extension View {
    func keyboardHeight(_ state: Binding<CGFloat>, onKeyboardHide: (() -> Void)? = nil) -> some View {
        self.modifier(KeyboardProvider(keyboardHeight: state, onKeyboardHide: onKeyboardHide))
    }
}


struct ActionSheetView<Content: View>: View {
    let content: Content
    let topPadding: CGFloat
    let fixedHeight: Bool
    let bgColor: Color
    
    @State private var screenHeight: CGFloat = UIScreen.main.bounds.height
    @State private var keyboardHeight: CGFloat = 0
    
    
    init(topPadding: CGFloat = 100, fixedHeight: Bool = false, bgColor: Color = .init(.secondarySystemBackground), @ViewBuilder content: () -> Content) {
        self.content = content()
        self.topPadding = topPadding
        self.fixedHeight = fixedHeight
        self.bgColor = bgColor
    }
    
    var body: some View {
        ZStack {
            bgColor.cornerRadius(16, corners: [.topLeft, .topRight])
            VStack {
                Color(.tertiarySystemBackground)
                    .opacity(0.8)
                    .frame(width: 30, height: 6)
                    .clipShape(Capsule())
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                
                content
                    .applyIf(fixedHeight) {
                        $0.frame(height: UIScreen.main.bounds.height - topPadding)
                    }
                    .applyIf(!fixedHeight) {
                        $0.frame(
                            maxHeight: calculateMaxHeight(),
                            alignment: .top
                        )
                    }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .keyboardHeight($keyboardHeight)
        .animation(.easeOut(duration: 0.16), value: keyboardHeight)
        .offset(y: -keyboardHeight)
    }
    
    private func calculateMaxHeight() -> CGFloat {
        max(screenHeight - topPadding - keyboardHeight, 150)
    }
}
