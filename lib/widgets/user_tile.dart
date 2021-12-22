import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../screens/user_detail_screen.dart';

class UserTile extends StatelessWidget {
  String dist;
  String name;
  String phone;
  String email;
  double latitude;
  double longitude;
  String id;
  bool isSentRequest;
  UserTile({
    required this.dist,
    required this.name,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.id,
    required this.isSentRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 18, bottom: 18, left: 18),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width - 88),
                    child: Text(
                      name,
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).accentColor),
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  dist == '-1'
                      ? Text('Disatnce: unknown')
                      : Text('Distance: ' + dist + "km"),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Mobile: ' + phone),
                ],
              ),
              Expanded(child: Container()),
              IconButton(
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDetailScreen(
                                isSentRequest: isSentRequest,
                                id: id,
                                dist: dist,
                                name: name,
                                phone: phone,
                                email: email,
                                latitude: latitude,
                                longitude: longitude)));
                  },
                  icon: Icon(Icons.arrow_forward_ios_rounded))
            ],
          ),
        ));
  }
}
