using UnrealBuildTool;

public class RuntimeAssetImportSampleTarget : TargetRules
{
    public RuntimeAssetImportSampleTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Game;
        DefaultBuildSettings = BuildSettingsVersion.Latest;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        GlobalDefinitions.Add("__has_feature(x)=0");
        ExtraModuleNames.Add("RuntimeAssetImportSample");
    }
}
