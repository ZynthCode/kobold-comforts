# Vintage Story Modding Conventions

> [!note] 
> 
> This is my attempt to gather the key takeaways from all the various Vintage Story modding documentation that is spread far and wide on the wiki page. Feel free to create PRs with improvements to this.

## Overview

Vintage Story mods can be created through C# programming (code mods) or by creating JSON assets and content files (content mods), or both. This document separates conventions into two main categories: **Coding** for C# development and **Content** for JSON assets, textures, shapes, and localization. Vintage Story has conventions that mod developers commonly follow for consistency and to reduce conflicts across mods.

## Quick reference

- **Blocks:** `Block{Name}` (example: `BlockTrampoline`)
- **Items:** `Item{Name}` (example: `ItemThornsBlade`)
- **Block entities:** `BE{Name}` (example: `BEAnvil`)
- **Entities:** `Entity{Name}` (example: `EntityEarthworm`)
- **Behaviors:** descriptive name (optional `Behavior` suffix), registered under a string code
- **Mod entry point:** one class extending `ModSystem` (often named after the mod)

# Coding

This section covers C# programming conventions for Vintage Story code mods.

## C# naming conventions (optional project style)

Some projects choose to deviate from common C# conventions where they harm readability. This is a project-level decision, and standard C# conventions (with "I" prefix for interfaces) are equally valid.

### Interfaces: No "I" prefix (alternative approach)

- **Good:** `Feature`, `Config`, `Handler`
- **Avoid:** `IFeature`, `IConfig`, `IHandler`

**An interface IS the thing, not "an interface of" the thing!** A `Feature` interface represents what a feature is. The "I" prefix adds noise without adding meaning.

**Implementation names become much cleaner!** With `IFeature`, you end up with awkward names like `FeatureImpl` or `FeatureBase`. With `Feature`, implementations are naturally named: `TrashCompactorFeature`, `TeleportFeature`.

## Class naming conventions

Vintage Story code commonly uses a `{Type}{Name}` style for classes, where the type communicates what the class represents.

- **Block classes:** Use the prefix `Block` followed by the block name (example: `BlockTrampoline`). Each block class extends the base `Block` class.

- **Item classes:** Use the prefix `Item` followed by the item name (example: `ItemThornsBlade`). Each item class extends the base `Item` class.

- **Block entity classes:** Use the prefix `BE` (Block Entity) followed by the entity name (examples: `BEAnvil`, `BEBed`). In JSON, block entities are referenced without the `BE` prefix. For example, the block JSON might contain `"entityClass": "Anvil"`, which corresponds to the code class `BEAnvil`.

- **Entity classes:** Use the prefix `Entity` for custom creatures or entities (example: `EntityEarthworm`). This matches vanilla patterns such as `EntityWolf` and `EntityPlayer`. Ensure you register your entity class in code.

- **Behavior classes:** If you create block behaviors or entity behaviors (classes extending `BlockBehavior`, `CollectibleBehavior`, or `EntityBehavior`), use a descriptive name that reflects what it does. Many mods use a short name (example: `Moving`), while others add a `Behavior` suffix for clarity (example: `ExplosionDropNerfBehavior`). Behaviors are also registered under a string code, which is often similar to the class name.

- **Mod system classes:** Every code mod should include a class extending `ModSystem` as the entry point. By convention, it is often named after the mod (example: `TrampolineMod`). It typically registers blocks, items, entities, behaviors, and other systems in its `Start` method.

## Code organization and structure

Vintage Story mod templates and common practice encourage organizing code by category to keep projects maintainable.

- **Folders and namespaces:** Group classes in folders by type (for example, `Blocks`, `Items`, `Entities`). Match this in namespaces. If your project is named `VSTutorial`, a block class in a `Blocks` folder commonly uses a namespace like `VSTutorial.Blocks`. The top level namespace is usually your mod name or a capitalized form of your mod ID.

- **One class per file:** Keep one class per `.cs` file, and name the file the same as the class (example: `BlockTrampoline.cs`, `ItemThornsBlade.cs`).

- **Access modifiers:** Mod classes do not need to be `public` unless they must be accessed from other assemblies. Many mods keep block and item classes `internal`. Your `ModSystem` entry point is typically `public` so the game can load it.

## Registering classes (avoiding collisions)

In your `ModSystem.Start`, register custom classes using a lowercase string that combines your mod ID and a short identifier, commonly based on the asset code. Example:

```csharp
api.RegisterBlockClass(Mod.Info.ModID + ".trampoline", typeof(BlockTrampoline));
```

The same idea applies to `RegisterItemClass`, `RegisterEntityClass`, `RegisterBlockEntityClass`, and similar APIs.

## User-facing messages and formatting

User-facing text in Vintage Story may be parsed as formatted text (VTML). This affects places like handbook content and can also affect other displayed messages. Because VTML uses angle brackets for tags, unescaped `<` and `>` can be interpreted as markup instead of literal characters.

- **Treat messages as markup-aware:** Chat output, command help, error messages, and other user-facing strings should be written as if a markup parser may read them.
- **Avoid raw angle brackets:** Do not use `<arg>` style placeholders in messages. Prefer `[arg]`, `(arg)`, or `{arg}`.
- **Escape when needed:** If you must show literal `<` or `>`, escape them as `&lt;` and `&gt;`.
- **Use formatting intentionally:** Only use VTML tags when you explicitly want formatting, and keep chat output simple and readable.
- **Prefer lang keys:** Do not hardcode player-facing strings when a lang key is practical (this also helps keep formatting consistent across the mod).

**Examples**:

- Good: `/spawnnear range [min] [max]`
- Good: `/spawnnear range &lt;min&gt; &lt;max&gt;`
- Avoid: `/spawnnear range <min> <max>`

### VTML formatting for player notifications

Player-facing notifications use consistent VTML formatting with the `<font>` tag:

**Syntax reference:**

`<font size="num" color="hexcolor" weight="bold" lineheight="1.2" align="right" opacity="0.5">text</font>`

**Standard styles:**

- Feature prefix (normal): `<font color="#88cc88" weight="bold">[FeatureName]</font>` (soft green, bold)
- Feature prefix (error): `<font color="#cc8888" weight="bold">[FeatureName]</font>` (soft red, bold)
- Key values (numbers, states): `<font weight="bold">{value}</font>` (bold)

**Example:**

```csharp
player.SendMessage(0, $"<font color=\"#88cc88\" weight=\"bold\">[SpawnNear]</font> Respawning <font weight=\"bold\">{distance:F0}</font> blocks from your death.", EnumChatType.Notification);
```

This ensures mod messages are visually distinct from regular chat and maintain a consistent brand identity across all Better Survival features.

## Command system conventions

Vintage Story provides a built-in command help system accessed via `/help`. Leverage this system rather than creating custom help handlers.

- **Use `.WithDescription()`:** Every command and subcommand should have a clear description. **Important:** Descriptions only appear when using `/help` - they do NOT appear in the basic subcommand listing when you type `/command`. When you type `/command`, you only see "Choose a subcommand: [list]" without descriptions.

- **Avoid custom help subcommands:** As a rule of thumb, avoid creating `/mycommand help` subcommands. Users expect `/help mycommand` to work, and the built-in system already provides this.

- **Avoid redundant status handlers:** Do not create handlers on intermediate nodes that just echo available subcommands. When a user types an incomplete command, the built-in system automatically shows "Choose a subcommand: [list]".

- **Status commands show actual state:** Only create explicit status/info commands when showing complex state that isn't obvious from the command structure. Examples:
  - Good: `/mycommand status` showing current configuration, overrides, and policy settings
  - Good: `/mycommand info` showing detailed behavior and explanations
  - Avoid: `/mycommand default` handler that just says "Default is ON. Use /mycommand default on|off"

- **Context-aware handlers:** If you need different behavior for different privilege levels, handle it in the same command handler:

  ```csharp
  public TextCommandResult HandleStatus(TextCommandCallingArgs args)
  {
      var player = args.Caller.Player as IServerPlayer;
      if (player.HasPrivilege(Privilege.controlserver))
          return ShowAdminStatus(args);
      else
          return ShowPlayerStatus(player);
  }
  ```

- **Arguments vs subcommands:** Choose between arguments and subcommands based on discoverability:
  - **Use subcommands** when values are enumerable/predictable (policies, modes, on/off toggles)
  - **Use arguments** only when values are dynamic/unpredictable (player names, numbers, free text)

  **Good (discoverable):**
  ```csharp
  .BeginSubCommand("set")
      .BeginSubCommand("strict")
          .WithDescription("Fall back to world spawn immediately on death")
          .HandleWith(handler)
      .EndSubCommand()
      .BeginSubCommand("adaptive")
          .WithDescription("Try multiple strategies before falling back to world spawn on death")
          .HandleWith(handler)
      .EndSubCommand()
  .EndSubCommand()
  ```
  
  **Avoid (not discoverable):**
  ```csharp
  .BeginSubCommand("set")
      .WithArgs(_api.ChatCommands.Parsers.Word("policy"))
      .HandleWith(handler)
  .EndSubCommand()
  ```
  
  When users type `/help mycommand set`, subcommands show all options with descriptions. String arguments only show `<policy is a string without spaces>`.

- **Argument placement:** Place arguments on the subcommand that uses them, not on parent nodes. This allows intermediate nodes to display helpful subcommand lists instead of "Argument X is missing" errors.

- **Multi-argument commands:** For commands requiring multiple arguments, include the full usage syntax in the description. This helps users who use `/help` to discover commands:

  **Good:**
  ```csharp
  .BeginSubCommand("config")
      .WithDescription("Set configuration: /mycommand config [name] [value] [option]")
      .WithArgs(parser1, parser2, parser3)
      .HandleWith(handler)
  .EndSubCommand()
  ```
  
  **Avoid:**
  ```csharp
  .BeginSubCommand("config")
      .WithDescription("Set custom configuration")
      .WithArgs(parser1, parser2, parser3)
      .HandleWith(handler)
  .EndSubCommand()
  ```
  
  **Limitation:** The built-in system only shows missing arguments one at a time when typing commands directly. Descriptions (including usage syntax) only appear in `/help` output, not in the basic subcommand listing. Users typing `/command subcommand` will still see "Argument X is missing" one at a time, but `/help command subcommand` will show the full usage syntax.

**Benefits of using the built-in system:**
- More discoverable - users see available subcommands automatically
- Less code to maintain
- Consistent with game conventions
- `/help` provides detailed usage information including argument parsers

----

# Content

This section covers JSON assets, textures, shapes, localization, and other content creation conventions.

## Mod ID and domain conventions

Every mod has a **mod ID** (also called a **domain**) that namespaces its assets.

- **Mod ID format:** The mod ID is defined in `modinfo.json` and should be lowercase alphanumeric with no spaces or special characters. For example, `"modId": "mycoolmod"` is valid, while `"MyCoolMod"` and `"my-cool-mod"` are not.

- **Domain usage:** A domain is the prefix before the colon in an asset location such as `mycoolmod:trampoline`. The base game commonly uses the `game` domain (and sometimes other domains in its own asset layout), while your mod uses your mod ID as its domain. Inside your own mod assets, you can often omit the domain because the game assumes your mod domain when none is provided. When referencing base game or other mod assets, include the domain explicitly.

- **Unique naming:** Use your mod domain consistently to avoid conflicts. Two mods can both have a block code `trampoline` because they are distinct assets as `alice:trampoline` and `bob:trampoline`.

## Asset naming and JSON conventions

Much of Vintage Story content is defined via JSON assets (block types, item types, entity types, and more). The conventions below help keep assets discoverable and consistent.

- **Asset file structure:** Under `assets/{modid}`, organize assets by category. Common folders include `blocktypes/`, `itemtypes/`, `entities/`, `shapes/`, `textures/`, `lang/`, and `patches/`. You can also use subfolders for organization, similar to the base game.

- **JSON file naming:** The JSON filename typically matches the asset code. For example, a block with `"code": "trampoline"` is commonly stored as `trampoline.json` under `assets/{modid}/blocktypes/`. Use lowercase codes, and prefer hyphens for multi word codes (example: `chest-labeled`).

- **JSON `code` property:** The `code` field defines the asset identifier within its domain.

  - Implicit mod domain (inside your mod):

    ```json
    { "code": "trampoline" }
    ```

  - Explicit domain (referencing another domain):

    ```json
    { "code": "game:granite" }
    ```

- **Class attachment in JSON:** If an asset needs a custom C# class, add a `"class"` property in the JSON. The value must match the name you registered in code. Conventionally, include your mod ID in that registry name. Example:

  ```json
  {
    "code": "trampoline",
    "class": "vstutorial.trampoline"
  }
  ```

  Place `"class"` near the top (often directly after `"code"`) so it is easy to spot.

- **JSON patch file naming:** Patch file names are flexible, but a common convention is to mirror the target path using hyphens. For example, a patch targeting `game:blocktypes/wood/bed.json` might be named `game-blocktypes-wood-bed.json` and placed under `assets/{modid}/patches/`.

- **Asset referencing:** When referencing shapes, textures, and similar assets, omit the domain for your own assets and include it for external assets.

  - Mod asset reference (implicit domain): `"item/simplewand"`
  - Base game reference (explicit domain): `"game:block/stone/granite"`

## Localization (lang file) conventions

Mods can provide localization by adding entries to a language file (for example, `en.json`) under `assets/{modid}/lang/`.

- **Auto generated keys:** The game generates default localization keys for most assets based on type and code. The pattern is typically `{type}-{code}`. Examples: `block-simplyshinyblock`, `item-simplewand`. In your lang file, map keys to display strings:

  ```json
  {
    "block-simplyshinyblock": "Simple Gold Block",
    "item-simplewand": "Simple Wand"
  }
  ```

- **Other lang keys:** For custom UI, behavior text, and messages, define your own keys with a consistent scheme. Many mods prefix by area or system (example: `gui-alloymixer-title`) or include the mod ID in the key to reduce collisions.

- **No hard coded strings:** Prefer lang keys for user facing text instead of hard coding strings in code or JSON.

- **Maintaining multiple languages:** If you provide multiple language files, keep keys identical across locales and only change values.

## References

- [Code Tutorial Simple Block: Creating a Block Class](https://wiki.vintagestory.at/Modding:Code_Tutorial_Simple_Block#Creating_a_Block_Class)
- [Code Tutorial Simple Item: Creating an Item Class](https://wiki.vintagestory.at/Modding:Code_Tutorial_Simple_Item#Creating_an_Item_Class)
- [Block Entity Classes (some data might be outdated)](https://wiki.vintagestory.at/Modding:Block_Entity_Classes)
- [Adding Block Behavior](https://wiki.vintagestory.at/Modding:Adding_Block_Behavior)
- [Advanced Blocks: Creating a Trampoline](https://wiki.vintagestory.at/Modding:Advanced_Blocks/en)
- [Modinfo](https://wiki.vintagestory.at/Modding:Modinfo)
- [modinfo.json schema](https://moddbcdn.vintagestory.at/schema/modinfo.latest.json)
- [Asset System](https://wiki.vintagestory.at/Modding:Asset_System)
- [Asset System: Asset Folder Location and Structure](https://wiki.vintagestory.at/Modding:Asset_System#Asset_Folder_Location_and_Structure)
- [Asset System: Domains (prefixes)](https://wiki.vintagestory.at/Modding:Asset_System#Domains)
- [Content Tutorial Basics: Shape Files](https://wiki.vintagestory.at/Modding:Content_Tutorial_Basics/en#Shape_Files)
- [Content Tutorial Basics: Texture Files](https://wiki.vintagestory.at/Modding:Content_Tutorial_Basics/en#Texture_Files)
- [Content Tutorial Basics: Language File](https://wiki.vintagestory.at/Modding:Content_Tutorial_Basics/en#Lang(uage)_File)
- [JSON Patch Reference](https://wiki.vintagestory.at/Modding:JSON_Patch_Reference)
- [JSON Patch Reference: Operations (addMerge, add, addEach, remove, replace, move, copy)](https://wiki.vintagestory.at/Modding:JSON_Patch_Reference#Operations)
- [VTML: Vintagetext Markup Language](https://wiki.vintagestory.at/VTML)
