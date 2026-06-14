import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class InputTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? prefixIcon;

  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Key? fieldKey;

  final bool enabled;
  final bool obscureText;

  const InputTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.validator,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.fieldKey,
    this.obscureText = false,
  });

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late bool _obscureText;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(InputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode?.hasFocus ?? false);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(AppRadius.md);
    final borderColor = _focused
        ? colorScheme.secondary
        : colorScheme.outline.withValues(alpha: 0.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: colorScheme.secondary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        key: widget.fieldKey,
        controller: widget.controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        onFieldSubmitted: widget.onFieldSubmitted,
        obscureText: widget.obscureText ? _obscureText : false,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint ?? widget.label,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          floatingLabelStyle: TextStyle(
            color: colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: colorScheme.onSurfaceVariant)
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: OutlineInputBorder(borderRadius: borderRadius),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: colorScheme.secondary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: colorScheme.error),
          ),
          errorStyle: TextStyle(
            color: colorScheme.tertiary,
            fontWeight: FontWeight.bold,
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: colorScheme.error, width: 2),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}
