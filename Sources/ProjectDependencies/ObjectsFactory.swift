import XcodeProj

final class ObjectsFactory {
    private(set) var objects: [PBXObject] = []
    
    func create<T: PBXObject>(objectFactory: () -> (T)) -> T {
        let object = objectFactory()
        objects.append(object)
        return object
    }
}
