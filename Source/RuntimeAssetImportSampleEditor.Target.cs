using UnrealBuildTool;

public class RuntimeAssetImportSampleEditorTarget : TargetRules
{
    public RuntimeAssetImportSampleEditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("RuntimeAssetImportSample");
    }
}
