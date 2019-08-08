import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  @override
  _DropDownState createState() => _DropDownState();
}

class Sites {
  int id;
  String name;
  Sites(this.id, this.name);
  static List<Sites> getSites() {
    return <Sites>[Sites(1, 'Site 1'), Sites(2, 'Site 2')];
  }
}

class _DropDownState extends State<DropDown> {
  List<Sites> _sites = Sites.getSites();
  List<DropdownMenuItem<Sites>> _dropDownMenuItems;
  Sites _selectedSite;
  @override
  void initState() {
    _dropDownMenuItems = buildDropDownMenuItem(_sites);
    _selectedSite = _dropDownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<Sites>> buildDropDownMenuItem(List sites) {
    List<DropdownMenuItem<Sites>> items = List();
    for (Sites site in sites) {
      items.add(DropdownMenuItem(
        value: site,
        child: Text(site.name, style: (TextStyle(fontSize: 18.0))),
      ));
    }
    return items;
  }

  onChangeDropDownItem(Sites selectedSite) {
    setState(() {
      _selectedSite = selectedSite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
          icon: Icon(Icons.language),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
          hintText: 'Please select expense',
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            value: _selectedSite,
            isDense: true,
            items: _dropDownMenuItems,
            onChanged: onChangeDropDownItem,
          ),
        ));
  }
}
