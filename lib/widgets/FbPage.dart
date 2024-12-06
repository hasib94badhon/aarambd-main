import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FbPage extends StatelessWidget {
  final List<dynamic> pages;

  FbPage({required this.pages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buisness'),
      ),
      body: ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) {
          final post = pages[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlueAccent,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                children: [
                  Image.network(
                    'https://aarambd.com/photo/${post['photo']}',
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) {
                      // This widget is shown if the image fails to load
                      return Image.network(
                        'https://via.placeholder.com/1000?text=No Image Found', // Fallback image URL
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.fitWidth,
                      );
                    },
                  ),
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.white, size: 20),
                          SizedBox(width: 4.0),
                          Text('${post['view']}',
                              style: TextStyle(color: Colors.white,fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('${post['time']}',
                          style: TextStyle(color: Colors.white,fontSize: 16)),
                    ),
                  ),
                  Positioned(
                    bottom: 50.0,
                    left: 8.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white60.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${post['name']}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${post['cat']}',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50.0,
                    right: 20.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Phone Icon with hidden number
                        Container(
                          child: InkWell(
                            onTap: () async {
                              final phoneNumber = post['phone'];
                              final telUrl = 'tel:$phoneNumber';
                              if (await canLaunch(telUrl)) {
                                await launch(telUrl);
                              } else {
                                // Handle the error, perhaps show a message to the user
                                print('Could not launch $telUrl');
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(35)
                                  ),
                                  child: Icon(Icons.phone, color: Colors.white,size: 35,)),
                                SizedBox(width: 4.0),
                                // The phone number is hidden, no Text widget displaying the number
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 10.0), // Add some space between the icons
                        // Facebook Icon instead of link
                        Container(
                          padding: EdgeInsets.all(5),
                           
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(35)
                          ),
                          child: InkWell(
                            onTap: () async {
                              var facebookUrl = post['link'];
                              if (await canLaunch(facebookUrl)) {
                                await launch(facebookUrl);
                              } else {
                                // If the Facebook app is not installed, open the URL in a web browser
                                await launch(
                                    '${post['link']}');
                              }
                            },
                            child: Icon(
                              Icons
                                  .facebook, // Replace with appropriate Facebook icon if needed
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8.0,
                    left: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.thumb_up, color: Colors.white,size: 20,),
                              SizedBox(width: 4.0),
                          Text('${post['like']}',
                              style: TextStyle(color: Colors.white,fontSize: 18)),
                            ],
                          ),
                          
                          Row(
                            children: [
                              Icon(Icons.location_city, color: Colors.white,size: 20,),
                              SizedBox(width: 4.0),
                          // Text('${post['location']}',
                          //     style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          
                          Row(
                            children: [
                              Icon(Icons.share, color: Colors.white,size: 20,),
                              SizedBox(width: 4.0),
                          Text('${post['share']}',
                              style: TextStyle(color: Colors.white,fontSize: 18)),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
