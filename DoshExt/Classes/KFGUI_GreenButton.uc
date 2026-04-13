class KFGUI_GreenButton extends KFGUI_Button;

function DrawMenu()
{
    local float XL, YL, TS;
    local byte i;

    if (bDisabled)
        Canvas.SetDrawColor(0, 32, 0, 255);
    else if (bPressedDown)
        Canvas.SetDrawColor(64, 255, 64, 255);
    else if (bFocused)
        Canvas.SetDrawColor(45, 180, 45, 255);
    else
        Canvas.SetDrawColor(8, 164, 8, 255);

    if (bIsHighlighted)
    {
        Canvas.DrawColor.R = Min(Canvas.DrawColor.R + 25, 255);
        Canvas.DrawColor.G = Min(Canvas.DrawColor.G + 25, 255);
        Canvas.DrawColor.B = Min(Canvas.DrawColor.B + 25, 255);
    }

    Canvas.SetPos(0.f, 0.f);
    if (ExtravDir == 255)
        Owner.CurrentStyle.DrawWhiteBox(CompPos[2], CompPos[3]);
    else
        Owner.CurrentStyle.DrawRectBox(0, 0, CompPos[2], CompPos[3], Min(CompPos[2], CompPos[3]) * 0.2, ExtravDir);

    if (ButtonText != "")
    {
        i = Min(FontScale + Owner.CurrentStyle.DefaultFontSize, Owner.CurrentStyle.MaxFontScale);
        while (true)
        {
            Canvas.Font = Owner.CurrentStyle.PickFont(i, TS);
            Canvas.TextSize(ButtonText, XL, YL, TS, TS);
            if (i == 0 || (XL < (CompPos[2] * 0.95) && YL < (CompPos[3] * 0.95)))
                break;
            --i;
        }
        Canvas.SetPos((CompPos[2] - XL) * 0.5, (CompPos[3] - YL) * 0.5);
        if (bDisabled)
            Canvas.DrawColor = TextColor * 0.5f;
        else
            Canvas.DrawColor = TextColor;
        Canvas.DrawText(ButtonText, , TS, TS, TextFontInfo);
    }
}