# ProjectDependencies

This project illustrates how to use [XcodeProj](https://github.com/tuist/XcodeProj) to produce two targets in separate .xcodeproj files and have one target depend on the products of another target.

To see the process in action run:
```
swift run
open GeneratedProjects/AppModule.xcodeproj
```

build `AppModule` scheme and observe the resulting AppModule.app bundle in the products directory.
