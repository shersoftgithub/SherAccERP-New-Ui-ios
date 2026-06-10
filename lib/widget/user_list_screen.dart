
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheraccerp/models/company_user.dart';
import 'package:sheraccerp/service/api.dart';
import 'package:sheraccerp/util/res_color.dart';
import 'package:sheraccerp/widget/appbar_custom_widget.dart';
import 'package:sheraccerp/widget/loading.dart';
import 'user_details_screen.dart'; 

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with SingleTickerProviderStateMixin {
  var regId = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  List<CompanyUser>? _allUsers;
  List<CompanyUser>? _filteredUsers;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _load();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers() {
    if (_allUsers == null) return;
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers!.where((user) {
        return user.username.toLowerCase().contains(query) ||
               user.userType.toLowerCase().contains(query);
      }).toList();
    });
  }

  _load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      regId = (prefs.getString('regId') ?? "0");
    });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bagroundColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppbarWidgget(
            headTxt: 'User List',
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bagroundColor,
              bagroundColor.withOpacity(0.95),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: userList(),
        ),
      ),
    );
  }

  Widget userList() {
    return FutureBuilder<List<CompanyUser>>(
      future: getCompanyUserList(regId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _allUsers = snapshot.data;
          _filteredUsers ??= _allUsers;
          
          return Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _filteredUsers!.isEmpty
                    ? emptyState()
                    : userGrid(),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  "Error loading users",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        return const Loading();
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users...',
            hintStyle: TextStyle(
              fontFamily: 'poppins',
              color: Colors.grey[400],
            ),
            prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_4, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget userGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredUsers!.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers![index];
        return userCard(user);
      },
    );
  }

  Widget userCard(CompanyUser user) {
  return ClipRRect(
    child: Hero(
      key: ValueKey('user_card_${user.userId}'),
      tag: 'user_${user.userId}',
      createRectTween: (begin, end) {
        return MaterialRectCenterArcTween(begin: begin, end: end);
      },
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getUserTypeColor(user.userType).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getUserTypeColor(user.userType).withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          user.userType,
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _getUserTypeColor(user.userType),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            user.username.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'ID: ${user.userId}',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: user.active == "true" 
                                  ? Colors.green.withOpacity(0.1) 
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: user.active == "true" ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.active == "true" ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 10,
                                    color: user.active == "true" ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: InkWell(
        onTap: () {
           Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, animation, secondaryAnimation) => 
                    UserDetailsScreen(user: user),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  var tween = Tween(begin: 0.0, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeInOut));
                  
                  return FadeTransition(
                    opacity: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            ).then((updatedUser) {
              if (updatedUser != null && updatedUser is CompanyUser) {
                setState(() {
                  final index = _allUsers?.indexWhere((u) => u.userId == updatedUser.userId);
                  if (index != null && index != -1) {
                    _allUsers![index] = updatedUser;
                    _filterUsers(); 
                  }
                });
              }
            });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user.userType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getUserTypeColor(user.userType).withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    user.userType,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: _getUserTypeColor(user.userType),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user.username.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'ID: ${user.userId}',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.active == "true" 
                            ? Colors.green.withOpacity(0.1) 
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user.active == "true" ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.active == "true" ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 10,
                              color: user.active == "true" ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // Widget userCard(CompanyUser user) {
  //   return Hero(
  //     tag: 'user_${user.userId}',
  //   child: Material(
  //     color: const Color.fromRGBO(0, 0, 0, 0),
  //     child: InkWell(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           PageRouteBuilder(
  //             transitionDuration: const Duration(milliseconds: 400),
  //             pageBuilder: (context, animation, secondaryAnimation) => 
  //                 UserDetailsScreen(user: user),
  //             transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //               var tween = Tween(begin: 0.0, end: 1.0)
  //                   .chain(CurveTween(curve: Curves.easeInOut));
                
  //               return FadeTransition(
  //                 opacity: animation.drive(tween),
  //                 child: child,
  //               );
  //             },
  //           ),
  //         ).then((updatedUser) {
  //           if (updatedUser != null && updatedUser is CompanyUser) {
  //             setState(() {
  //               final index = _allUsers?.indexWhere((u) => u.userId == updatedUser.userId);
  //               if (index != null && index != -1) {
  //                 _allUsers![index] = updatedUser;
  //                 _filterUsers(); 
  //               }
  //             });
  //           }
  //         });
  //       },
  //       borderRadius: BorderRadius.circular(16),
  //       child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(16),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.grey.withOpacity(0.1),
  //                 spreadRadius: 1,
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2),
  //               ),
  //             ],
  //           ),
  //           child: Stack(
  //             clipBehavior: Clip.none,
  //             children: [
  //               Positioned(
  //                 top: 8,
  //                 right: 8,
  //                 child: Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //                   decoration: BoxDecoration(
  //                     color: _getUserTypeColor(user.userType).withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(12),
  //                     border: Border.all(
  //                       color: _getUserTypeColor(user.userType).withOpacity(0.3),
  //                       width: 0.5,
  //                     ),
  //                   ),
  //                   child: Text(
  //                     user.userType,
  //                     style: TextStyle(
  //                       fontFamily: 'poppins',
  //                       fontSize: 9,
  //                       fontWeight: FontWeight.w500,
  //                       color: _getUserTypeColor(user.userType),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(12),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     Text(
  //                       user.username.toUpperCase(),
  //                       style: const TextStyle(
  //                         fontFamily: 'poppins',
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 13,
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       textAlign: TextAlign.center,
  //                     ),
  //                     Text(
  //                       'ID: ${user.userId}',
  //                       style: TextStyle(
  //                         fontFamily: 'poppins',
  //                         fontSize: 11,
  //                         color: Colors.grey[600],
  //                       ),
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
                      
  //                     const SizedBox(height: 6),
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  //                       decoration: BoxDecoration(
  //                         color: user.active == "true" 
  //                             ? Colors.green.withOpacity(0.1) 
  //                             : Colors.red.withOpacity(0.1),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Container(
  //                             width: 6,
  //                             height: 6,
  //                             decoration: BoxDecoration(
  //                               shape: BoxShape.circle,
  //                               color: user.active == "true" ? Colors.green : Colors.red,
  //                             ),
  //                           ),
  //                           const SizedBox(width: 4),
  //                           Text(
  //                             user.active == "true" ? 'Active' : 'Inactive',
  //                             style: TextStyle(
  //                               fontFamily: 'poppins',
  //                               fontSize: 10,
  //                               color: user.active == "true" ? Colors.green : Colors.red,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Color _getUserTypeColor(String type) {
    return kPrimaryColor ;
    // switch (type) {
    //   case 'Admin':
    //     return Colors.red;
    //   case 'Manager':
    //     return Colors.orange;
    //   case 'Staff':
    //     return Colors.blue;
    //   case 'SalesMan':
    //     return Colors.green;
    //   default:
    //     return Colors.purple;
    // }
  }
}