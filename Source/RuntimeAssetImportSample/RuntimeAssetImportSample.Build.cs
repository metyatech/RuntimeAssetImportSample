using UnrealBuildTool;

public class RuntimeAssetImportSample : ModuleRules
{
    public RuntimeAssetImportSample(ReadOnlyTargetRules Target) : base(Target)
    {
        PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;
        PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine" });
    }
}
