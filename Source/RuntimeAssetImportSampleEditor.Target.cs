using UnrealBuildTool;

public class RuntimeAssetImportSampleEditorTarget : TargetRules
{
    public RuntimeAssetImportSampleEditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        bOverrideBuildEnvironment = true;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        GlobalDefinitions.Add("__has_feature(x)=0");
        ExtraModuleNames.Add("RuntimeAssetImportSample");
    }
}
