using Godot;

namespace Deepwild.addons.mouse_pan;

[Tool]
public partial class AdjustablePanning : EditorPlugin
{
    private const string XButton1Setting = "mouse_pan/xbutton1";
    private const string XButton2Setting = "mouse_pan/xbutton2";

    private bool _canvasInputConnected;
    
    private Control? _canvasViewport;
    private CheckBox? _xButton1CheckBox;
    private CheckBox? _xButton2CheckBox;
    private AcceptDialog? _configDialog;

    public override void _EnterTree()
    {
        ConnectCanvasInput();
        AddToolSubmenu();
        SetupConfigMenu();
    }

    public override void _ExitTree()
    {
        DisconnectCanvasInput();
        RemoveToolSubmenu();
        CleanupConfigMenu();
        _canvasViewport = null;
    }

    private void ConnectCanvasInput()
    {
        _canvasViewport = FindControlByClass(
            EditorInterface.Singleton.GetBaseControl(),
            "CanvasItemEditorViewport"
        );
        
        if (_canvasViewport == null || _canvasInputConnected)
            return;
        
        _canvasViewport.GuiInput += OnCanvasGuiInput;
        _canvasInputConnected = true;
    }

    private void DisconnectCanvasInput()
    {
        if (_canvasViewport == null || !_canvasInputConnected)
            return;
        
        _canvasViewport.GuiInput -= OnCanvasGuiInput;
        _canvasInputConnected = false;
    }

    private void AddToolSubmenu()
    {
        PopupMenu toolMenu = new PopupMenu();
        toolMenu.IndexPressed += ToolMenuHandler;
        
        toolMenu.AddItem("Open Config...");
        toolMenu.AddSeparator();
        toolMenu.AddItem("Reload Plugin");
        
        AddToolSubmenuItem("Adjustable Panning", toolMenu);
    }

    private void RemoveToolSubmenu()
    {
        RemoveToolMenuItem("Adjustable Panning");
    }

    private void ToolMenuHandler(long index)
    {
        switch (index)
        {
            case 0:
                OpenConfig();
                break;
            case 2:
                ReloadPlugin();
                break;
            default:
                GD.Print("Invalid index");
                break;
        }
    }

    private void ReloadPlugin()
    {
        DisconnectCanvasInput();
        
        ConnectCanvasInput();
    }
    
    private void SetupConfigMenu()
    {
        EditorSettings editorSettings = EditorInterface.Singleton.GetEditorSettings();
        
        if (!editorSettings.HasSetting(XButton1Setting)) 
            editorSettings.SetSetting(XButton1Setting, false);
        
        if (!editorSettings.HasSetting(XButton2Setting))
            editorSettings.SetSetting(XButton2Setting, true);
    }

    private void CleanupConfigMenu()
    {
        _configDialog?.QueueFree();
        
        _configDialog = null;
        _xButton1CheckBox = null;
        _xButton2CheckBox = null;
    }

    private void OpenConfig()
    {
        if (_configDialog != null)
        {
            _configDialog.PopupCentered();
            return;
        }

        _configDialog = new AcceptDialog
        {
            Title = "2D Panning Config",
            Size = new Vector2I(300, 180)
        };

        var container = new VBoxContainer();

        var description = new Label
        {
            Text = "Select which mouse buttons should pan the 2D editor."
        };

        _xButton1CheckBox = new CheckBox
        {
            Text = "Mouse Button 4",
            ButtonPressed = EditorInterface.Singleton.GetEditorSettings()
                .GetSetting(XButton1Setting).AsBool()
        };

        _xButton2CheckBox = new CheckBox
        {
            Text = "Mouse Button 5",
            ButtonPressed = EditorInterface.Singleton.GetEditorSettings()
                .GetSetting(XButton2Setting).AsBool()
        };
        
        container.AddChild(description);
        container.AddChild(_xButton1CheckBox);
        container.AddChild(_xButton2CheckBox);

        _configDialog.AddChild(container);
        EditorInterface.Singleton.GetBaseControl().AddChild(_configDialog);

        _configDialog.Confirmed += SaveConfig;
        _configDialog.Canceled += CleanupConfigMenu;
        
        _configDialog.PopupCentered();
    }

    private void SaveConfig()
    {
        EditorInterface.Singleton.GetEditorSettings()
            .SetSetting(XButton1Setting, _xButton1CheckBox?.ButtonPressed ?? false);
        EditorInterface.Singleton.GetEditorSettings()
            .SetSetting(XButton2Setting, _xButton2CheckBox?.ButtonPressed ?? true);

        CleanupConfigMenu();
    }

    private static Control? FindControlByClass(Node node, string className)
    {
        if (node is Control control && control.GetClass() == className)
            return control;

        foreach (Node child in node.GetChildren())
        {
            Control? result = FindControlByClass(child, className);

            if (result != null)
                return result;
        }

        return null;
    }

    private void OnCanvasGuiInput(InputEvent @event)
    {
        if (@event is not InputEventMouseButton mouseButton) return;
        
        if (!IsConfiguredButton(mouseButton.ButtonIndex)) return;
        
        var middleButton = new InputEventMouseButton
        {
            ButtonIndex = MouseButton.Middle,
            Pressed = mouseButton.Pressed,
            Position = mouseButton.Position,
            GlobalPosition = mouseButton.GlobalPosition
        };
        
        _canvasViewport?.EmitSignal(Control.SignalName.GuiInput, middleButton);
    }

    private bool IsConfiguredButton(MouseButton button)
    {
        var settings = EditorInterface.Singleton.GetEditorSettings();

        return button switch
        {
            MouseButton.Xbutton1 =>
                settings.GetSetting(XButton1Setting).AsBool(),

            MouseButton.Xbutton2 =>
                settings.GetSetting(XButton2Setting).AsBool(),

            _ => false
        };
    }
}