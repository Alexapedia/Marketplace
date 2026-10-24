import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/maison.dart';
import '../utils/functions/responsive.dart';

class AppTextField extends StatefulWidget {
  final TextInputAction textInputAction;
  final TextInputType textInputType;
  final bool obscureText;
  final FocusNode? focusNode;
  final int? maxlines;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final String title;
  final void Function()? onTap;
  final IconData? suffixIcon;
  final List<TextInputFormatter> inputFormatters;
  final IconData? prefexIcon;
  final Widget? suffixIconWidget;
  final bool isReadOnly;
  final String? hintText;
  final Function(String)? onChange;

  const AppTextField({
    super.key,
    this.validator,
    this.hintText,
    this.textInputAction = TextInputAction.next,
    this.textInputType = TextInputType.emailAddress,
    this.obscureText = false,
    this.title = '',
    this.onTap,
    this.onChange,
    this.suffixIcon,
    this.focusNode,
    this.inputFormatters = const [],
    required this.controller,
    this.maxlines = 1,
    this.prefexIcon,
    this.suffixIconWidget,
    this.isReadOnly = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = context.maison;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) ...[
            ExcludeSemantics(
              child: Text(
                widget.title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: _isFocused ? m.accentInk : m.inkMuted,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Semantics(
            label: widget.title.isEmpty ? null : widget.title,
            textField: true,
            child: TextFormField(
              onChanged: widget.onChange,
              inputFormatters: widget.inputFormatters,
              textInputAction: widget.textInputAction,
              maxLines: widget.maxlines,
              keyboardType: widget.textInputType,
              focusNode: _focusNode,
              controller: widget.controller,
              readOnly: widget.isReadOnly,
              validator: widget.validator,
              obscureText: widget.obscureText,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: context.font(15),
                color: m.ink,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                suffixIcon:
                    widget.suffixIconWidget ??
                    (widget.suffixIcon == null
                        ? null
                        : GestureDetector(
                            onTap: widget.onTap,
                            child: Icon(widget.suffixIcon),
                          )),
                prefixIcon: widget.prefexIcon == null
                    ? null
                    : Icon(widget.prefexIcon, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
