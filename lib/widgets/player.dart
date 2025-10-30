import 'package:flutter/material.dart';

class PlayerCounter extends StatefulWidget {
  const PlayerCounter({super.key});

  @override
  State<PlayerCounter> createState() => _PlayerCounterState();
}

class _PlayerCounterState extends State<PlayerCounter> {
  int _counter = 0;

  void _addCounter() {
    setState(() {
      _counter++;
    });
  }

  void _subCounter() {
    setState(() {
      _counter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(onPressed: _subCounter, child: Text('-')),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          ElevatedButton(onPressed: _addCounter, child: Text('+')),
        ],
      ),
    );
  }
}
