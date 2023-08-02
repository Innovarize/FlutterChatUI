

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/src/util.dart';

/// A class that represents send button widget
class SendButton extends StatelessWidget {
  /// Creates send button widget
  const SendButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  /// Callback for send button tap event
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
   //   height: 24,
      margin: const EdgeInsets.only(left: 16),
   //   width: 24,
      child:   Container(
        height: 47,
        width: 47,
        decoration: BoxDecoration(

            shape: BoxShape.circle,
            border: Border.all(color: AppColor.textAndStarGrey,width: 2)
        ),
        child:   Center(
          child: InkWell(
            onTap: onPressed,
            child: Container(
              height:37,
              width: 37,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primaryColor
              ),
              child: Center(
                  child:
                  SizedBox(
                    height:22,
                    width: 22,
                     child: Image.asset(
                        'assets/send.jpg',
                        color: AppColor.white,
                        package: 'flutter_chat_ui',
                      )
                  //  child: Image.asset('lib/assets/send.jpg',color: AppColor.white,),
                  ) ),
            ),
          ),
        ),
      ),
    );
  }
}
