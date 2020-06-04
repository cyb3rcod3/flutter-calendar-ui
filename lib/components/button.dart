import 'package:flutter/material.dart';

class FillFlatButton extends StatelessWidget {
  const FillFlatButton({Key key, this.onPressed, this.text}) : super(key: key);
  final VoidCallback onPressed;
  final String text;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:onPressed,
      child: Container(
        height: 48,
        color: Theme.of(context).accentColor,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.done,
              size: 20,
              color: Theme.of(context).accentIconTheme.color,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              text,
              style: Theme.of(context).accentTextTheme.button,
            ),
            SizedBox(
              width: 28,
            ),
          ],
        ),
      ),
    );
  }
}