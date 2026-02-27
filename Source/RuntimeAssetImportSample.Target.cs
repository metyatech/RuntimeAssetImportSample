using UnrealBuildTool;

public class RuntimeAssetImportSampleTarget : TargetRules
{
    public RuntimeAssetImportSampleTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("RuntimeAssetImportSample");
    }
}
