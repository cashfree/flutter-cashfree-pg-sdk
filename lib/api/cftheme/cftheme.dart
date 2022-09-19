class CFThemeBuilder {
  String _primaryTextColor = "#11385b";
  String _secondaryTextColor = "#808080";
  String _backgroundColor = "#FFFFFF";
  String _navigationBarBackgroundColor = "#6A3FD3";
  String _navigationBarTextColor = "#FFFFFF";
  String _primaryFont = "";
  String _secondaryFont = "";
  String _buttonBackgroundColor = "#6A3FD3";
  String _buttonTextColor = "#FFFFFF";

  CFThemeBuilder setPrimaryTextColor(String primaryTextColor) {
    _primaryTextColor = primaryTextColor;
    return this;
  }

  CFThemeBuilder setSecondaryTextColor(String secondaryTextColor) {
    _secondaryTextColor = secondaryTextColor;
    return this;
  }

  CFThemeBuilder setBackgroundColor(String backgroundColor) {
    _backgroundColor = backgroundColor;
    return this;
  }

  CFThemeBuilder setNavigationBarBackgroundColorColor(String navigationBarBackgroundColor) {
    _navigationBarBackgroundColor = navigationBarBackgroundColor;
    return this;
  }

  CFThemeBuilder setNavigationBarTextColor(String navigationBarTextColor) {
    _navigationBarTextColor = navigationBarTextColor;
    return this;
  }

  CFThemeBuilder setPrimaryFont(String primaryFont) {
    _primaryFont = primaryFont;
    return this;
  }

  CFThemeBuilder setSecondaryFont(String secondaryFont) {
    _secondaryFont = secondaryFont;
    return this;
  }

  CFThemeBuilder setButtonBackgroundColor(String buttonBackgroundColor) {
    _buttonBackgroundColor = buttonBackgroundColor;
    return this;
  }

  CFThemeBuilder setButtonTextColor(String buttonTextColor) {
    _buttonTextColor = buttonTextColor;
    return this;
  }

  CFTheme build() {
    return CFTheme(this);
  }

  String getPrimaryTextColor() {
    return _primaryTextColor;
  }

  String getSecondaryTextColor() {
    return _secondaryTextColor;
  }

  String getBackgroundColor() {
    return _backgroundColor;
  }

  String getNavigationBarBackgroundColor() {
    return _navigationBarBackgroundColor;
  }

  String getNavigationBarTextColor() {
    return _navigationBarTextColor;
  }

  String getPrimaryFont() {
    return _primaryFont;
  }

  String getSecondaryFont() {
    return _secondaryFont;
  }

  String getButtonBackgroundColor() {
    return _buttonBackgroundColor;
  }

  String getButtonTextColor() {
    return _buttonTextColor;
  }

}

class CFTheme {

  String _primaryTextColor = "#11385b";
  String _secondaryTextColor = "#808080";
  String _backgroundColor = "#FFFFFF";
  String _navigationBarBackgroundColor = "#6A3FD3";
  String _navigationBarTextColor = "#FFFFFF";
  String _primaryFont = "";
  String _secondaryFont = "";
  String _buttonBackgroundColor = "#6A3FD3";
  String _buttonTextColor = "#FFFFFF";

  CFTheme._();

  CFTheme(CFThemeBuilder builder) {
    _primaryTextColor = builder.getPrimaryTextColor();
    _secondaryTextColor = builder.getSecondaryTextColor();
    _backgroundColor = builder.getBackgroundColor();
    _navigationBarBackgroundColor = builder.getNavigationBarBackgroundColor();
    _navigationBarTextColor = builder.getNavigationBarTextColor();
    _primaryFont = builder.getPrimaryFont();
    _secondaryFont = builder.getSecondaryFont();
    _buttonBackgroundColor = builder.getButtonBackgroundColor();
    _buttonTextColor = builder.getButtonTextColor();
  }

  String getPrimaryTextColor() {
    return _primaryTextColor;
  }

  String getSecondaryTextColor() {
    return _secondaryTextColor;
  }

  String getBackgroundColor() {
    return _backgroundColor;
  }

  String getNavigationBarBackgroundColor() {
    return _navigationBarBackgroundColor;
  }

  String getNavigationBarTextColor() {
    return _navigationBarTextColor;
  }

  String getPrimaryFont() {
    return _primaryFont;
  }

  String getSecondaryFont() {
    return _secondaryFont;
  }

  String getButtonBackgroundColor() {
    return _buttonBackgroundColor;
  }

  String getButtonTextColor() {
    return _buttonTextColor;
  }
}