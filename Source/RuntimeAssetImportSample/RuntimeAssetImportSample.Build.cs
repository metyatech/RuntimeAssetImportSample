using UnrealBuildTool;

public class RuntimeAssetImportSample : ModuleRules
{
    public RuntimeAssetImportSample(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        bEnableUndefinedIdentifierWarnings = false;
        PublicDefinitions.Add("__has_feature(x)=0");

        PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore" });
    }
}
