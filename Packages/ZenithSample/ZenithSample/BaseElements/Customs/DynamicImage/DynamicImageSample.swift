import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct DynamicImageSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State private var selectedStyle = DynamicImageStyleCase.smallContentA
    @State private var imageSource = ImageSource.systemImage
    @State private var systemImageName = "checkmark"
    @State private var customURL = "https://img.icons8.com/ios/50/domain--v1.png"
    @State private var selectedImageName = ImageName.logo
    @State private var searchText = ""
    @State private var imageWidth: Double = 100
    @State private var imageHeight: Double = 100
    @State private var maintainAspectRatio = true
    @State private var resizableEnabled = true
    @State private var isShowingSymbolPicker = false
    @State private var showFixedHeader = false

    enum ImageSource: String, CaseIterable, Identifiable {
        case systemImage = "Sistema"
        case customURL = "URL"
        case imageName = "Image Name"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    // Preview da imagem com estilo selecionado
                    VStack {
                        previewImage
                            .frame(width: imageWidth, height: imageHeight)
                            .scaledToFit()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(alignment: .leading, spacing: 12) {
                    configurationSection
                    
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
            }
        )
    }
    
    var previewImage: some View {
        Group {
            switch imageSource {
            case .systemImage:
                DynamicImage(systemImageName, resizable: resizableEnabled)
                    .dynamicImageStyle(selectedStyle.style())
            case .customURL:
                DynamicImage(customURL, resizable: resizableEnabled)
                    .dynamicImageStyle(selectedStyle.style())
            case .imageName:
                DynamicImage(selectedImageName, resizable: resizableEnabled)
                    .dynamicImageStyle(selectedStyle.style())
            }
        }
    }
    
    var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Fonte da imagem
            VStack(alignment: .leading) {
                Text("Fonte da Imagem")
                Picker("Fonte da Imagem", selection: $imageSource) {
                    ForEach(ImageSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)
                
                // Campos específicos para cada fonte
                switch imageSource {
                case .systemImage:
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Ícone do Sistema:")
                            Spacer()
                            Button(action: {
                                // Abrir a sheet para selecionar o ícone
                                isShowingSymbolPicker = true
                            }) {
                                HStack {
                                    Image(systemName: systemImageName)
                                        .frame(width: 24, height: 24)
                                    Text(systemImageName)
                                        .lineLimit(1)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .sheet(isPresented: $isShowingSymbolPicker) {
                        SystemSymbolPicker(
                            selectedSymbol: $systemImageName
                        )
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                    }
                case .customURL:
                    TextField("URL da imagem", text: $customURL)
                        .textFieldStyle(.roundedBorder)
                case .imageName:
                    Picker("ImageName", selection: $selectedImageName) {
                        ForEach(ImageName.allCases) { name in
                            Text(name.rawValue).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            // Dimensões da imagem
            VStack(alignment: .leading) {
                Text("Dimensões")
                
                Toggle("Manter proporção", isOn: $maintainAspectRatio)
                Toggle("Resizable", isOn: $resizableEnabled)
                
                HStack {
                    Text("Largura:")
                    Slider(value: $imageWidth, in: 20...300) { editing in
                        if maintainAspectRatio && !editing {
                            imageHeight = imageWidth
                        }
                    }
                    Text("\(Int(imageWidth))")
                        .frame(width: 40)
                }
                
                HStack {
                    Text("Altura:")
                    Slider(value: $imageHeight, in: 20...300) { editing in
                        if maintainAspectRatio && !editing {
                            imageWidth = imageHeight
                        }
                    }
                    Text("\(Int(imageHeight))")
                        .frame(width: 40)
                }
            }
            
            // Estilo
            VStack(alignment: .leading) {
                Text("Estilo")
                TextField("Filtrar estilos", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredStyles, id: \.self) { style in
                            styleButton(style)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func styleButton(_ style: DynamicImageStyleCase) -> some View {
        Text(String(describing: style))
            .font(fonts.small)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedStyle == style ? colors.highlightA : colors.backgroundB)
            )
            .foregroundColor(selectedStyle == style ? colors.contentC : colors.contentA)
            .onTapGesture {
                selectedStyle = style
            }
    }
    
    var filteredStyles: [DynamicImageStyleCase] {
        if searchText.isEmpty {
            return DynamicImageStyleCase.allCases
        }
        return DynamicImageStyleCase.allCases.filter {
            String(describing: $0).lowercased().contains(searchText.lowercased())
        }
    }
    
    private func generateCode() -> String {
        var codeSource = ""
        
        switch imageSource {
        case .systemImage:
            codeSource = """
            DynamicImage("\(systemImageName)", resizable: \(resizableEnabled))
                .dynamicImageStyle(.\(String(describing: selectedStyle).lowercased())())
            """
        case .customURL:
            codeSource = """
            DynamicImage("\(customURL)", resizable: \(resizableEnabled))
                .dynamicImageStyle(.\(String(describing: selectedStyle).lowercased())())
            """
        case .imageName:
            codeSource = """
            DynamicImage(.\(selectedImageName.rawValue), resizable: \(resizableEnabled))
                .dynamicImageStyle(.\(String(describing: selectedStyle).lowercased())())
            """
        }
        
        return codeSource
    }
}
