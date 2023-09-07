// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

/// @Persistent is a property wrapper type that can read and write a persisted value saved in FileManager.
///
/// Use persistent as the single source of truth for a given value type that you
/// store in a view hierarchy. Create a persistent value in an ``App``, ``Scene``,
/// or ``View`` by applying the `@Persistent` attribute to a property declaration
/// and providing an initial value. Declare persistent as private to prevent setting
/// it in a memberwise initialize:
///
///     struct PlayButton: View {
///         @Persistent("isPlaying", defaultValue: false) private var isPlaying: Bool // Create the persistent variable.
///
///         var body: some View {
///             Button(isPlaying ? "Pause" : "Play") { // Read the value.
///                 isPlaying.toggle() // Write to the persistent variable.
///             }
///         }
///     }
///
/// When the value changes, SwiftUI updates the parts of the view hierarchy that depend on the value.
/// To access a persistent's underlying value, you use its ``wrappedValue`` property.
/// However, as a shortcut Swift enables you to access the wrapped value by
/// referring directly to the persistent instance. The above example reads and
/// writes the `isPlaying` persistent property's wrapped value by referring to the
/// property directly.
///
/// Declare persistent as private in the highest view in the view hierarchy that
/// needs access to the value. Then share the persistent with any subviews that also
/// need access, either directly for read-only access, or as a binding for
/// read-write access.
///
/// ### Share persistent with subviews
///
/// If you pass a persistent property to a subview, SwiftUI updates the subview
/// any time the value changes in the container view, but the subview can't
/// modify the value. To enable the subview to modify the persistent's stored value,
/// pass a ``Binding`` instead. You can get a binding to a persistent value by
/// accessing the persistent's ``projectedValue``, which you get by prefixing the
/// property name with a dollar sign (`$`).
///
/// For example, you can remove the `isPlaying` persistent from the play button in
/// the above example, and instead make the button take a binding:
///
///     struct PlayButton: View {
///         @Binding var isPlaying: Bool // Play button now receives a binding.
///
///         var body: some View {
///             Button(isPlaying ? "Pause" : "Play") {
///                 isPlaying.toggle()
///             }
///         }
///     }
///
/// Then you can define a player view that declares the persistent and creates a
/// binding to the persistent using the dollar sign prefix:
///
///     struct PlayerView: View {
///         @Persistent("isPlaying", defaultValue: false) private var isPlaying: Bool // Create the persistent here now.
///
///         var body: some View {
///             VStack {
///                 PlayButton(isPlaying: $isPlaying) // Pass a binding.
///
///                 // ...
///             }
///         }
///     }
///
/// Declare ``Persistent`` as private to prevent setting it in a memberwise initializer.
/// Use persistent for storage that's local to a view and its subviews and requires it to be persisted.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@frozen @propertyWrapper public struct Persistent<Value: Codable> : DynamicProperty {
    @State private var value: Value
    private var internalFilename: String
    
    /// The underlying value referenced by the binding variable.
    public var wrappedValue: Value {
        get { value }
        nonmutating set {
            FileSystem.write(newValue, to: internalFilename)
            value = newValue
        }
    }
    
    /// A projection of the binding value that returns a binding.
    public var projectedValue: Binding<Value> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    /// A property wrapper type that reflects a value from FileManager and works with all Codable types.
    /// - Parameters:
    ///   - filename: The name of the file you want FileManager to save to.
    ///   - defaultValue: The default value of the variable upon first initialisation of its type.
    public init(_ fileName: String, defaultValue: Value) {
        internalFilename = fileName
        if let result = FileSystem.read(Value.self, from: fileName) {
            _value = State(wrappedValue: result)
        } else {
            _value = State(wrappedValue: defaultValue)
        }
    }
}
