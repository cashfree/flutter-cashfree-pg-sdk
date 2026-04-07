/// Builder for creating a [CFTheme] to customize the payment UI appearance.
///
/// All color values are hex strings (e.g., `"#FFFFFF"`). Fonts are font family name strings.
/// Example:
/// ```dart
/// final theme = CFThemeBuilder()
///   .setPrimaryTextColor("#000000")
///   .setButtonBackgroundColor("#6A3FD3")
///   .build();
/// ```
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

  /// Sets the primary text color (hex string, e.g. `"#11385b"`).
  CFThemeBuilder setPrimaryTextColor(String primaryTextColor) {
    _primaryTextColor = primaryTextColor;
    return this;
  }

  /// Sets the secondary text color (hex string).
  CFThemeBuilder setSecondaryTextColor(String secondaryTextColor) {
    _secondaryTextColor = secondaryTextColor;
    return this;
  }

  /// Sets the background color of the payment sheet (hex string).
  CFThemeBuilder setBackgroundColor(String backgroundColor) {
    _backgroundColor = backgroundColor;
    return this;
  }

  /// Sets the navigation bar background color (hex string).
  CFThemeBuilder setNavigationBarBackgroundColorColor(String navigationBarBackgroundColor) {
    _navigationBarBackgroundColor = navigationBarBackgroundColor;
    return this;
  }

  /// Sets the navigation bar text/icon color (hex string).
  CFThemeBuilder setNavigationBarTextColor(String navigationBarTextColor) {
    _navigationBarTextColor = navigationBarTextColor;
    return this;
  }

  /// Sets the primary font family name.
  CFThemeBuilder setPrimaryFont(String primaryFont) {
    _primaryFont = primaryFont;
    return this;
  }

  /// Sets the secondary font family name.
  CFThemeBuilder setSecondaryFont(String secondaryFont) {
    _secondaryFont = secondaryFont;
    return this;
  }

  /// Sets the payment button background color (hex string).
  CFThemeBuilder setButtonBackgroundColor(String buttonBackgroundColor) {
    _buttonBackgroundColor = buttonBackgroundColor;
    return this;
  }

  /// Sets the payment button text color (hex string).
  CFThemeBuilder setButtonTextColor(String buttonTextColor) {
    _buttonTextColor = buttonTextColor;
    return this;
  }

  /// Builds and returns a [CFTheme] with the configured values.
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

/// Holds the visual theme configuration for the Cashfree payment UI.
///
/// Create instances using [CFThemeBuilder].
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

  /// Returns the primary text color hex string.
  String getPrimaryTextColor() {
    return _primaryTextColor;
  }

  /// Returns the secondary text color hex string.
  String getSecondaryTextColor() {
    return _secondaryTextColor;
  }

  /// Returns the background color hex string.
  String getBackgroundColor() {
    return _backgroundColor;
  }

  /// Returns the navigation bar background color hex string.
  String getNavigationBarBackgroundColor() {
    return _navigationBarBackgroundColor;
  }

  /// Returns the navigation bar text color hex string.
  String getNavigationBarTextColor() {
    return _navigationBarTextColor;
  }

  /// Returns the primary font family name.
  String getPrimaryFont() {
    return _primaryFont;
  }

  /// Returns the secondary font family name.
  String getSecondaryFont() {
    return _secondaryFont;
  }

  /// Returns the button background color hex string.
  String getButtonBackgroundColor() {
    return _buttonBackgroundColor;
  }

  /// Returns the button text color hex string.
  String getButtonTextColor() {
    return _buttonTextColor;
  }
}
