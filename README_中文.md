# UnattendedWinstall 无人值守的 Windows 安装工具

## 导言

UnattendedWinstall 无人值守的 Windows 安装利用了微软的 [应答文件](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/update-windows-settings-and-scripts-create-your-own-answer-file-sxs?view=windows-11) （或无人参与文件）来自动化和定制 Windows 安装。</br> 它能够在安装过程中直接在 Windows ISO 中对 Windows 设置和软件包进行修改。

### 为何使用应答文件？

#### 安全

- 通过允许检查应答文件中的所有更改来提供透明度。 
- 直接在微软官方的 Windows ISO 上运行，无需使用非官方来源。 
- 利用了微软支持的一项功能，该功能旨在简化 Windows 安装的大规模部署。 

#### 自动

- 能够在多个设备上实现自动化配置，通过消除重复的手动设置来节省时间和精力。 

> [!注意] 
> UnattendedWinstall 无人值守的 Windows 安装已针对个人使用进行了测试和优化。对于那些有进一步定制需求的用户，请按照 [这个视频指南](https://youtu.be/WyLiJl-NQU8)[创建你自己的应答文件](https://schneegans.de/windows/unattend-generator/) 。

### 版本

[![Version 2 Release (Latest)](https://img.shields.io/badge/Version-2.1.0%20Latest-0078D4?style=for-the-badge&logo=github&logoColor=white)](https://github.com/memstechtips/UnattendedWinstall/releases/tag/v2.1.0)
[![Version 1 Release](https://img.shields.io/badge/Version-1.0.0-FFA500?style=for-the-badge&logo=github&logoColor=white)](https://github.com/memstechtips/UnattendedWinstall/releases/tag/v1.0.0)

### 支持项目

如果无人值守的 Windows 安装对您有用，请考虑支持该项目，这真的很有帮助！ 

[![Support via PayPal](https://img.shields.io/badge/Support-via%20PayPal-FFD700?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/memstech)

### 反馈和社区

如果您对无人值守的 Windows 安装有反馈、建议或需要帮助，请随时在 GitHub 或我们的 Discord 社区参与讨论： 

[![Join the Discussion](https://img.shields.io/badge/Join-the%20Discussion-2D9F2D?style=for-the-badge&logo=github&logoColor=white)](https://github.com/memstechtips/UnattendedWinstall/discussions)
[![Join Discord Community](https://img.shields.io/badge/Join-Discord%20Community-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://www.discord.gg/zWGANV8QAX)

## 要求

- Windows 10 或 Windows 11  
  - *(在 Windows 10 22H2 & Windows 11 24H2 上进行了测试)*
  - *(支持 32-bit, 64-bit 和 arm64)*

## UnattendedWinstall 做什么？

无人值守的 Windows 安装应答文件几乎为所有配置和注册表调整都提供了详细描述，可在 GitHub 上此处查看。如需自定义，下载应答文件并在诸如 [Cursor](https://www.cursor.com/) 或 [VSCode](https://code.visualstudio.com/) 等编辑器中打开。

### 来源和贡献

<details>
  <summary>点击显示</summary>

- **生成基本应答文件**:
  - [Schneegans Unattend Generator](https://schneegans.de/windows/unattend-generator/)
- **调整和优化**:
  - [ChrisTitusTech WinUtil](https://github.com/ChrisTitusTech/winutil)
  - [FR33THY's Ultimate Windows Optimization Guide](https://github.com/FR33THYFR33THY/Ultimate-Windows-Optimization-Guide)
- **其他调整**:
  - [Tiny11Builder](https://github.com/ntdevlabs/tiny11builder)
  - [Ten Forums](https://www.tenforums.com/)
  - [Eleven Forum](https://www.elevenforum.com/)
  - [Winaero Tweaker](https://winaerotweaker.com/)

</details>

### 主要特点

- 能够选择 Windows 版本（从 v2.0.0 版本起不再强制为专业版） 
- 绕过 Windows 11 系统要求 
- 默认情况下禁用 Windows Defender 服务 
  - *在 Windows 安装后会提示启用 *
- 默认情况下禁用用户账户控制 
  - *在 Windows 安装后会提示启用 *
- 默认情况下允许执行 PowerShell 脚本 
- 在 Windows 安装过程中跳过强制创建微软账户 
- 移除预装的臃肿软件应用程序，但微软 Edge、记事本和计算器除外 
  - Copilot 和 Recall 禁用。 
- 设置与隐私相关的注册表项以禁用遥测功能 
- 将 Windows 更新限制为在一年内仅安装安全更新 
- 使用各种优化和自定义相关的键来优化注册表 
  - *有关更多信息，请参阅“Set-RecommendedHKLMRegistry”（设置推荐的 HKLM 注册表）和“Set-RecommendedHKCURegistry”（设置推荐的 HKCU 注册表）函数 *
- 禁用不必要的计划任务 
- 为实现最佳性能配置 Windows 服务 
- 启用“Ultimate Performance”（终极性能）电源计划

> [!注意] 
> 在 Windows 安装完成后，使用 `UWScript.ps1` 文件重新应用或还原设置，以防 Windows 更新重置某些设置，或者如果您遇到任何问题。 
> 它还可用于在现有运行的 Windows 安装上实现与 UnattendedWinstall 无人值守 Windows 安装类似的体验，而无需重新安装 Windows。 
> 
> ---
> 
> **在运行脚本之前**
> 
> 请确保以管理员身份打开 PowerShell。另外，通过运行以下命令设置执行策略以允许脚本执行： 
> 
> ```powershell
> Set-ExecutionPolicy Unrestricted
> ```
> 
> 以提升的权限运行 PowerShell 并启用脚本执行将确保 `UWScript.ps1` 能够应用必要的系统更改。 

## 使用说明

若要使用应答文件，请将 `autounattend.xml` 包含在 Windows 安装介质的根目录中，以便在 Windows 安装过程中执行。 

> [!重要]  
> 确保应答文件命名为 `autounattend.xml`；否则，安装程序将无法识别它。 

---

### 使用 Memory 的 [WIMUtil](https://github.com/memstechtips/WIMUtil) （强烈推荐）

要使用 **WIMUtil**，请按照以下步骤以管理员身份启动 PowerShell 并运行安装脚本：

1. **以管理员身份打开PowerShell：**
   
   - **Windows 10/11**：右键单击 **开始** 按钮，然后选择 **Windows PowerShell (Admin)** 或 **Windows Terminal (Admin)**。 </br> PowerShell 将在新窗口中打开。 

2. **确认管理员权限**：
   
   - 如果用户帐户控制 (UAC) 提示，单击 **是** 以允许 PowerShell 以管理员身份运行。 

3. **粘贴并运行命令**：
   
   - 复制以下命令：
     
     ```powershell
     irm "https://github.com/memstechtips/WIMUtil/raw/main/src/WIMUtil.ps1" | iex
     ```
   
   - 要粘贴到 PowerShell 中，在 PowerShell 或终端窗口中 **右键单击** 或按 **Ctrl + V**。  </br> 这应该会自动粘贴您复制的命令。 
   
   - 按 **Enter** 键执行命令。 

Once launched, **WIMUtil** guides you through a wizard:

1. **选择或下载 Windows ISO**
2. **自动添加最新的 UnattendedWinstall 无人值守 Windows 安装应答文件 **
3. **提取并将当前设备驱动程序添加到安装介质 **
4. **创建包含自定义项的新 ISO**
5. **使用 [Ventoy](https://github.com/ventoy/Ventoy) 创建可引导的 USB 闪存驱动器**
6. **将新的 ISO 文件复制到 Ventoy 闪存驱动器**
7. **从 USB 闪存驱动器启动，选择您的 ISO 并安装Windows**

有关更多信息，请查看官方的 [WIMUtil](https://github.com/memstechtips/WIMUtil) GitHub Repo。

---

### 旧方法

#### 方法 1：创建可引导的 Windows 安装 USB

- [视频教程](https://youtu.be/pDEZDD_gEbo)

<details>
  <summary>点击显示说明</summary>

1. 下载 `autounattend.xml` 文件并将其保存在您的计算机上。 

2. 使用 [Rufus](https://rufus.ie/en/) 或媒体创建工具创建 [Windows 10](https://www.microsoft.com/en-us/software-download/windows10) 或 [Windows 11](https://www.microsoft.com/en-us/software-download/windows11) 可引导的安装 USB 驱动器。
   
   > **重要**  
   > 
   > - 一些用户报告在使用媒体创建工具创建 Windows 安装 USB 时出现问题。请自行决定是否使用。 
   > - 使用 Rufus 时，不要选中 **自定义您的 Windows 体验** 中的任何复选框，因为这会创建另一个 `autounattend.xml` 文件，可能会覆盖 UnattendedWinstall 文件中的设置。 

3. 将您在步骤 1 中下载的 `autounattend.xml` 文件复制到您在步骤 2 中创建的可引导 Windows 安装 USB 的根目录。 

4. 从 Windows 安装 USB 启动，像平常一样进行 Windows 的全新安装，脚本将自动运行。 

</details>

#### 方法 2：创建自定义 ISO 文件

- [视频教程](https://youtu.be/pDEZDD_gEbo?si=ChEGghEOLCyLSnp7&t=1117)

<details>
  <summary>点击显示说明</summary>

1. 下载 `autounattend.xml` 文件并将其保存在您的计算机上。 

2. 根据您想要的版本下载 [Windows 10](https://www.microsoft.com/en-us/software-download/windows10) 或 [Windows 11](https://www.microsoft.com/en-us/software-download/windows11) 的 ISO 文件。

3. 下载和安装 [AnyBurn](https://anyburn.com/download.php)
   
   - 在 AnyBurn 中，选择“编辑镜像文件”选项。 
   - 导航至并选择您在步骤 2 中下载的官方 Windows ISO 文件。 
   - 点击“添加”并选择您在步骤 1 中下载的 `autounattend.xml` 文件，或者直接点击并将 `autounattend.xml` 拖入 AnyBurn 窗口。 
   - 点击“下一步”，然后点击“立即创建”。系统应该会提示您覆盖 ISO 文件；点击“是”。 
   - 一旦该过程完成，关闭 AnyBurn。 

4. 使用该 ISO 文件在虚拟机上安装 Windows ，或者使用像 [Rufus](https://rufus.ie/en/) 或 [Ventoy](https://github.com/ventoy/Ventoy) 这样的程序，用编辑后的 Windows ISO 文件创建可引导的 USB 闪存驱动器。
   
   > **重要**  
   > 
   > - 使用 Rufus 时，不要选中 **自定义您的 Windows 体验** 中的任何复选框，因为这会创建另一个 `autounattend.xml` 文件，该文件可能会覆盖 UnattendedWinstall 文件中的设置。 

5. 从 Windows 安装 USB 启动，像平常一样进行 Windows 的全新安装，脚本将自动运行。 

</details>

#### 方法 3：使用 Ventoy 自动安装插件

- [视频教程](https://youtu.be/4AGZQJTyCOs)

<details>
  <summary>点击显示说明</summary>

1. 下载 `autounattend.xml` 文件并将其保存到您的计算机上。 
2. 根据您想要的版本，下载 [Windows 10](https://www.microsoft.com/en-us/software-download/windows10) 或 [Windows 11](https://www.microsoft.com/en-us/software-download/windows11) 的 ISO 文件。
3. 下载并将 [Ventoy](https://github.com/ventoy/Ventoy) 安装到您想要的 USB 闪存驱动器上。
4. 准备文件夹结构： 
   - 在您新创建的 Ventoy USB 磁盘中，创建以下文件夹：`ISO` 和 `Templates`。  <br/> *它们应该在驱动器的根目录。 *
     -在 `ISO` 文件夹内，创建一个名为 `Windows` 的新文件夹。 
     -将您的 Windows ISO 文件复制到 `ISO\Windows` 文件夹中。 
   - 将您的 `autounattend.xml` 复制到 `Templates` 文件夹中。 
5. 启动 VentoyPlugson。根据您的操作系统，步骤可能会有所不同。 
   - 在 Windows 上，运行 `VentoyPlugson.exe` 文件。 
   - 应该会打开一个新的浏览器窗口，其中带有准备就绪的 Ventoy 网络界面。 
   - 从列表中选择 `自动安装插件` 菜单。 
   - 点击 `添加` 按钮。
   - 选择 [parent（父级）] 以使整个 Windows ISO 文件夹受益于该插件。 
   - 在目录路径中，粘贴您的 `Windows`  文件夹的绝对路径。 <br/> 例如： `F:\ISO\Windows` （将 `F` 替换为您的驱动器盘符。） 
   - 在模板路径中，粘贴您的 `autounattend.xml` 文件的绝对路径。  <br/>例如： `F:\Templates\autounattend.xml` （将 `F` 替换为您的驱动器盘符。）  <br/> （PSA：如果您有更多的 `autounattend.xml` 文件，您可以稍后添加它们！）  
   - 点击 `OK` ，您应该会看到一条消息，提示配置已成功保存。 
   - 关闭 VentoyPlugson 浏览器窗口并停止 VentoyPlugson 应用程序。 
6. 在您想要安装 Windows 的计算机上从 Ventoy USB 驱动器启动。 
   - 选择要从中启动的 Windows ISO 后，系统将提示您使用 `/Templates/autounattend.xml` 文件启动。 
   - 选择该选项，`autounattend.xml` 将在安装过程中自动执行。 

</details>

## 常见问题解答

### 我如何将这些设置应用于现有的 Windows 安装？

- 运行 [`UWScript.ps1`](https://github.com/memstechtips/UnattendedWinstall/blob/main/UWScript.ps1) 文件或使用 [Chris Titus Tech Windows Utility](https://github.com/ChrisTitusTech/winutil) ([视频教程](https://youtu.be/pldFPTnOCGM))。

### 这个应答文件可以用于就地升级吗？

- 不，就地升级不支持应答文件。 

### 为什么 Windows 仍在自动更新？

- 功能更新延迟一年；然而，安全和驱动程序更新照常进行。 

### 安装 Windows 后为什么我没有网络？

<details>
  <summary>点击显示说明</summary>

  如果您在安装后无法连接到互联网，很可能是因为您的 Wi-Fi 或 LAN（以太网）驱动程序缺失。Windows 有时不包含网络适配器的所有必要驱动程序，特别是如果它们是您设备特有的。 

  要解决此问题，请按照以下步骤操作： 

1. **下载您的网络驱动程序** 在另一台可上网的电脑上从制造商的网站下载您的网络驱动程序。查找特定于您设备型号的 Wi-Fi 或 LAN 驱动程序。 

2. **传输驱动程序** 通过 U 盘将驱动程序传输到您的 Windows 安装中。 

3. **安装驱动程序** 在您的 Windows 系统上安装驱动程序，如有必要，请重新启动。 
   安装完成后，您应该能够连接到互联网。 

</details>

### 我如何访问该文件之前的“IoT-LTSC 类”、“标准”和“核心”版本？

- 您仍然可以在此处访问之前的文件：[版本 1.0.0 发布](https://github.com/memstechtips/UnattendedWinstall/releases/tag/v1.0.0).
  
  > [!注意]  
  > 您需要下载 `Source Code.zip` 文件。解压后，您将能够访问所有之前的 v1.0.0 文件。 

### 为什么 Microsoft Edge 没有被卸载？

<details>
  <summary>点击显示说明</summary>

  我花了很多时间试图在 Windows 安装期间找到卸载 Microsoft Edge 的方法。然而，由于 Windows 10 22H2 和 Windows 11 24H2 之间的差异，这具有挑战性。我的目标是使用微软支持的卸载方法，并且我计划在未来的版本中添加一个简单的 Edge 移除选项。 

  与此同时，如果您希望在 Windows 安装后删除 Edge，可以考虑使用 [FR33THY 的这个脚本](https://github.com/FR33THYFR33THY/Ultimate-Windows-Optimization-Guide/blob/main/6%20Windows/14%20Edge.ps1). FR33THY 的 *Ultimate Windows Optimization Guide*《终极 Windows 优化指南》对这个项目的 2.0.0 版本是一个重要的启发，并且我强烈推荐探索它以获取更多 Windows 优化技巧。 

</details>

### 我如何将我自己的注册表调整添加到 `autounattend.xml` 文件的 v2.0.0 版本中？

<details>
  <summary>点击显示说明</summary>

  您仍然可以将自己的注册表项添加到v2.0.0文件中，如果您了解在哪里添加它，实际上会更容易。我简单解释一下。

  对于适用于本地计算机的注册表项，即 `HKEY_LOCAL_MACHINE` 注册表键，您可以在 `autounattend.xml` 文件中找到 `function SetRecommendedHKLMRegistry` ，请查看这里：https://github.com/memstechtips/UnattendedWinstall/blob/93305192ed6d64e0f5b98a89f447927480285354/autounattend.xml#L1981

  然后以 `.reg` 格式添加您想要添加的任何注册表项，就像设置其余的项一样，并且确保在 `"@` 之前添加它，使其成为将生成的 `.reg` 文件的一部分，请看这里：https://github.com/memstechtips/UnattendedWinstall/blob/93305192ed6d64e0f5b98a89f447927480285354/autounattend.xml#L3412

  然后它将被应用到注册表中。 

  同样，如果您有 `HKEY_CURRENT_USER` 注册表键，您可以按照上述解释的相同方式将其添加到 `User Customization.ps1` 文件中，从这里开始：
https://github.com/memstechtips/UnattendedWinstall/blob/93305192ed6d64e0f5b98a89f447927480285354/autounattend.xml#L3912
  所以在 `Windows Registry Editor Version 5.00` 下面，然后在 `"@` 之前结束，这里： https://github.com/memstechtips/UnattendedWinstall/blob/93305192ed6d64e0f5b98a89f447927480285354/autounattend.xml#L4423

> **注意**  
> 一旦文件的新版本发布，上述链接可能不会将您带到正确的代码行，但它确实会将您带到v2.0.0上的正确行。

</details>
