import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../flutter_chat_ui.dart';
import '../util.dart';
import 'inherited_chat_theme.dart';

class NewLineIntent extends Intent {
  const NewLineIntent();
}

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget
  const Input({
    Key? key,
    this.isAttachmentUploading,
    this.isWeb,
    this.onAttachmentPressed,
    this.onLocationPressed,
    required this.onSendPressed,
    this.onTextChanged,
    this.onTextFieldTap,
    required this.sendButtonVisibilityMode,
  }) : super(key: key);

  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;
  final void Function()? onLocationPressed;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;
  final bool? isWeb;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText) onSendPressed;

  /// Will be called whenever the text inside [TextField] changes
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap
  final void Function()? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  @override
  _InputState createState() => _InputState();
}

/// [Input] widget state
class _InputState extends State<Input> {
  final _inputFocusNode = FocusNode();
  bool _sendButtonVisible = true;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sendButtonVisible = true;
    // if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
    //   _sendButtonVisible = _textController.text.trim() != '';
    //   _textController.addListener(_handleTextControllerChange);
    // } else {
    //   _sendButtonVisible = true;
    // }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  Widget _leftWidget() {
    if (widget.isAttachmentUploading == true) {
      return Container(
        height: 24,
        margin: const EdgeInsets.only(right: 16),
        width: 24,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            InheritedChatTheme.of(context).theme.inputTextColor,
          ),
        ),
      );
    } else {
      return Row(
        children: [
          AttachmentButton(onPressed: widget.onAttachmentPressed),
          LocationButton(onPressed: widget.onLocationPressed),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);

    return GestureDetector(
      onTap: () => _inputFocusNode.requestFocus(),
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): const SendMessageIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
              const NewLineIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.shift):
              const NewLineIntent(),
        },
        child: Actions(
          actions: {
            SendMessageIntent: CallbackAction<SendMessageIntent>(
              onInvoke: (SendMessageIntent intent) => _handleSendPressed(),
            ),
            NewLineIntent: CallbackAction<NewLineIntent>(
              onInvoke: (NewLineIntent intent) {
                final _newValue = '${_textController.text}\r\n';
                _textController.value = TextEditingValue(
                  text: _newValue,
                  selection: TextSelection.fromPosition(
                    TextPosition(offset: _newValue.length),
                  ),
                );
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Material(
                borderRadius: BorderRadius.circular(55),
                color:
                    widget.isWeb == true
                        ? AppColor.backgroundColor
                        : AppColor.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      if (widget.onAttachmentPressed != null) _leftWidget(),
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 5),
                        height: 20,
                        child: const VerticalDivider(
                          color: AppColor.dividerColor,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          cursorColor:
                              InheritedChatTheme.of(
                                context,
                              ).theme.inputTextCursorColor,
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Type something here',
                            hintStyle: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              fontSize: 13,
                              color: AppColor.textAndStarGrey,
                            ),
                          ),
                          // decoration: InheritedChatTheme.of(context).theme.inputTextDecoration.copyWith(hintStyle: InheritedChatTheme.of(context).theme
                          //           .inputTextStyle
                          //           .copyWith(
                          //             color: InheritedChatTheme.of(context)
                          //                 .theme
                          //                 .inputTextColor
                          //                 .withOpacity(0.5),
                          //           ),
                          //       hintText: InheritedL10n.of(context)
                          //           .l10n
                          //           .inputPlaceholder,
                          //     ),
                          focusNode: _inputFocusNode,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          onChanged: widget.onTextChanged,
                          onTap: widget.onTextFieldTap,
                          style: InheritedChatTheme.of(context)
                              .theme
                              .inputTextStyle
                              .copyWith(color: AppColor.black),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      Visibility(
                        visible: _sendButtonVisible,
                        child: SendButton(onPressed: _handleSendPressed),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
