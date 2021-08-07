import XcodeProj
import Foundation

let repositoryRoot = URL(
    fileURLWithPath: #filePath
).appendingPathComponent("../../..").standardized

let appModuleName = "AppModule"
let moduleWithResourcesName = "ModuleWithResources"

let appModuleProjectPath = repositoryRoot.appendingPathComponent("GeneratedProjects/\(appModuleName).xcodeproj").path
let moduleWithResourcesProjectPath = repositoryRoot.appendingPathComponent("GeneratedProjects/\(moduleWithResourcesName).xcodeproj").path

let moduleWithResourcesProduct = try createModuleWithResources()
try createAppModule(moduleWithResourcesProduct: moduleWithResourcesProduct)

func createModuleWithResources() throws -> ProductToImport {
    let factory = ObjectsFactory()
    
    let product = factory.create {
        PBXFileReference(
            sourceTree: .buildProductsDir,
            name: "\(moduleWithResourcesName).bundle",
            explicitFileType: Xcode.filetype(extension: "bundle"),
            path: "\(moduleWithResourcesName).bundle"
        )
    }

    let buildConfigurationsList = factory.create {
        XCConfigurationList(
            buildConfigurations: [
                factory.create {
                    XCBuildConfiguration(
                        name: "Debug",
                        buildSettings: [
                            "PRODUCT_NAME": "\(moduleWithResourcesName)"
                        ]
                    )
                }
            ]
        )
    }
    
    let resourceToBundle = factory.create {
        PBXFileReference(
            sourceTree: .group,
            name: "resource",
            path: "resource"
        )
    }
    
    let target: PBXTarget = factory.create {
        PBXNativeTarget(
            name: moduleWithResourcesName,
            buildConfigurationList: buildConfigurationsList,
            buildPhases: [
                factory.create {
                    PBXResourcesBuildPhase(
                        files: [
                            factory.create {
                                PBXBuildFile(
                                    file: resourceToBundle
                                )
                            }
                        ]
                    )
                }
            ],
            productName: "\(moduleWithResourcesName)",
            product: product,
            productType: .bundle
        )
    }
    
    let project = factory.create {
        PBXProject(
            name: moduleWithResourcesName,
            buildConfigurationList: buildConfigurationsList,
            compatibilityVersion: "Xcode 12.0",
            mainGroup: factory.create {
                PBXGroup(
                    children: [
                        factory.create {
                            PBXGroup(
                                children: [
                                    resourceToBundle
                                ],
                                sourceTree: .absolute,
                                name: "Resources",
                                path: repositoryRoot.appendingPathComponent("\(moduleWithResourcesName)/Resources").path
                            )
                        },
                        factory.create {
                            PBXGroup(
                                children: [
                                    product
                                ],
                                sourceTree: .buildProductsDir,
                                name: "Products"
                            )
                        }
                    ],
                    sourceTree: .absolute
                )
            },
            targets: [target]
        )
    }

    try XcodeProj(
        workspace: XCWorkspace(),
        pbxproj: PBXProj(
            rootObject: project,
            objects: factory.objects
        )
    ).write(
        pathString: moduleWithResourcesProjectPath,
        override: true
    )
    
    return ProductToImport(
        project: project,
        target: target,
        product: product
    )
}

func createAppModule(moduleWithResourcesProduct: ProductToImport) throws {
    let factory = ObjectsFactory()
    
    let appModuleProduct = factory.create {
        PBXFileReference(
            sourceTree: .buildProductsDir,
            name: "\(appModuleName).app",
            explicitFileType: Xcode.filetype(extension: "app"),
            path: "\(appModuleName).app"
        )
    }
    
    let moduleWithResourcesProjectReference = factory.create {
        PBXFileReference(
            sourceTree: .absolute,
            name: moduleWithResourcesProduct.project.name,
            explicitFileType: Xcode.filetype(extension: "xcodeproj"),
            path: moduleWithResourcesProjectPath
        )
    }

    let buildConfigurationsList = factory.create {
        XCConfigurationList(
            buildConfigurations: [
                factory.create {
                    XCBuildConfiguration(
                        name: "Debug",
                        buildSettings: [
                            "PRODUCT_NAME": "\(appModuleName)"
                        ]
                    )
                }
            ]
        )
    }

    let mainGroup: PBXGroup = factory.create {
        PBXGroup(
            children: [
                factory.create {
                    PBXGroup(
                        children: [
                            moduleWithResourcesProjectReference
                        ],
                        sourceTree: .group,
                        name: "Dependencies"
                    )
                },
                factory.create {
                    PBXGroup(
                        children: [
                            appModuleProduct
                        ],
                        sourceTree: .buildProductsDir,
                        name: "Products"
                    )
                }
            ],
            sourceTree: .absolute
        )
    }
    
    let moduleWithResourcesProductReference = factory.create {
        PBXReferenceProxy(
            fileType: moduleWithResourcesProduct.product.lastKnownFileType,
            path: moduleWithResourcesProduct.product.path,
            name: moduleWithResourcesProduct.product.name,
            remote: factory.create {
                PBXContainerItemProxy(
                    containerPortal: .fileReference(moduleWithResourcesProjectReference),
                    remoteGlobalID: .object(moduleWithResourcesProduct.product),
                    proxyType: .reference
                )
            },
            sourceTree: moduleWithResourcesProduct.product.sourceTree
        )
    }
    
    let moduleWithResourcesProductsReferenceGroup = factory.create {
        PBXGroup(
            children: [
                moduleWithResourcesProductReference
            ],
            sourceTree: .buildProductsDir,
            name: "Products"
        )
    }

    let resourcesPhase = factory.create {
        PBXResourcesBuildPhase(
            files: [
                factory.create {
                    PBXBuildFile(
                        file: moduleWithResourcesProductReference
                    )
                }
            ]
        )
    }

    let target: PBXTarget = factory.create {
        PBXNativeTarget(
            name: appModuleName,
            buildConfigurationList: buildConfigurationsList,
            buildPhases: [
                resourcesPhase
            ],
            dependencies: [
                factory.create {
                    PBXTargetDependency(
                        name: moduleWithResourcesProduct.target.name,
                        targetProxy: factory.create {
                            PBXContainerItemProxy(
                                containerPortal: .fileReference(moduleWithResourcesProjectReference),
                                remoteGlobalID: .object(moduleWithResourcesProduct.target),
                                proxyType: .nativeTarget
                            )
                        }
                    )
                }
            ],
            productName: "\(appModuleName)",
            product: appModuleProduct,
            productType: .application
        )
    }
    
    let proj = PBXProj(
        rootObject: factory.create {
            PBXProject(
                name: appModuleName,
                buildConfigurationList: buildConfigurationsList,
                compatibilityVersion: "Xcode 12.0",
                mainGroup: mainGroup,
                projects: [
                    [
                        Xcode.ProjectReference.productGroupKey: moduleWithResourcesProductsReferenceGroup,
                        Xcode.ProjectReference.projectReferenceKey: moduleWithResourcesProjectReference
                    ]
                ],
                targets: [target]
            )
        },
        objects: factory.objects
    )

    try XcodeProj(
        workspace: XCWorkspace(),
        pbxproj: proj
    ).write(
        pathString: appModuleProjectPath,
        override: true
    )
}
