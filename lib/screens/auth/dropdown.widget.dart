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
    return <Sites>[Sites(1, 'Site1'), Sites(2, 'Site2')];
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
        child: Text(site.name),
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
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Text('Select a site'),
            SizedBox(
              height: 10,
            ),
            DropdownButton(
              value: _selectedSite,
              items: _dropDownMenuItems,
              onChanged: onChangeDropDownItem,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text('Selected: ${_selectedSite.name}')
          ],
        ),
      ),
    );
  }
}
