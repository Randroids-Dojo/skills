# UMG Automation IDs

UMG widgets do not always expose driver IDs by default.

Recommended helper:

- `UPlayUnrealUMGAutomationLibrary::SetAutomationId(UWidget* Widget, FName Id)`
- Call in Widget Construct or NativeConstruct.
- Internally attach `FDriverMetaData::Id` to the underlying Slate widget.

If runtime metadata is awkward, implement a custom UWidget subclass that attaches
metadata during `RebuildWidget()`.
