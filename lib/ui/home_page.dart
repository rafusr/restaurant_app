import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/common/result_state.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/restaurant_provider.dart';
import 'package:restaurant_app/ui/detail_page.dart';
import 'package:restaurant_app/models/restaurant.dart';
// import 'package:restaurant_app/ui/favorite_page.dart';
import 'package:restaurant_app/ui/splash_page.dart';
import 'package:restaurant_app/widgets/platform_widget.dart';
import 'package:restaurant_app/common/styles.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home_page';
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Restaurants> _restaurant;

  @override
  void initState() {
    super.initState();
    _restaurant = ApiService().fetchList();
  }

  Widget _buildHome(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20.0, top: 70.0, right: 20.0),
        children: [
          Row(
            children: [
              RichText(
                text: TextSpan(
                  text: 'Hello ',
                  style: Theme.of(context).textTheme.bodyText1,
                  children: [
                    TextSpan(
                      text: widget.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: '!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ), /*
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.favorite
                ),
                onPressed: () {
                  Navigator.pushNamed(context, FavoritePage.routeName,
            arguments: List<restaurants>);
                },
              )*/
            ],
          ),
          const SizedBox(height: 10.0),
          const Divider(
            height: 5.0,
            color: secondaryColor,
          ),
          const SizedBox(height: 10.0),
          const ListTile(
            title: Text(
              'Restaurant',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Here\'s a restaurant recommendation for you!'),
          ),
          _buildList(context)
        ],
      ),
    ));
  }

  Widget _buildList(BuildContext context) {
    return Consumer<RestaurantProvider>(builder: (context, state, _) {
      if (state.state == ResultState.Loading) {
        return const Center(child: CircularProgressIndicator());
      } else if (state.state == ResultState.HasData) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.result.restaurants.length,
          itemBuilder: (context, index) {
            var restaurant = state.result.restaurants[index];
            return _buildItemList(context, restaurant);
          },
        );
      } else if (state.state == ResultState.NoData) {
        return Center(child: Text(state.message));
      } else if (state.state == ResultState.Error) {
        return Center(child: Text(state.message));
      } else {
        return const Center(child: Text(''));
      }
    });
    /*return FutureBuilder(
      future: _restaurant,
      builder: (context, AsyncSnapshot<Restaurants> snapshot) {
        var state = snapshot.connectionState;

        if (state != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data?.restaurants.length,
              itemBuilder: (context, index) {
                var restaurant = snapshot.data?.restaurants[index];
                return _buildItemList(context, restaurant!);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return const Text('');
          }
        }
        /*
        final List<Restaurants> restaurants = parseRestaurants(snapshot.data);
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return _buildItemList(context, restaurants[index]);
          },
        );
        */
      },
    );*/
  }

  Widget _buildItemList(BuildContext context, RestaurantElement restaurant) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      leading: SizedBox(
        width: 110,
        height: 120,
        child: Hero(
          tag: restaurant.pictureId,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: SizedBox.expand(
              child: Image.network(
                restaurant.pictureId,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        restaurant.name,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(restaurant.city),
      onTap: () {
        Navigator.pushNamed(context, RestaurantDetailPage.routeName,
            arguments: restaurant.id);
      },
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(SplashPage.routeName),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _buildAndroid(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: _buildHome(context),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CupertinoPageScaffold(
      child: _buildHome(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RestaurantProvider>(
        create: (_) => RestaurantProvider(apiService: ApiService()),
        child: PlatformWidget(
            androidBuilder: _buildAndroid, iosBuilder: _buildIos));
  }
}
