import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fl_starter/features/todos/models/todo_model.dart';
import 'package:fl_starter/features/todos/repositories/remote_todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fquery/fquery.dart';
import 'package:go_router/go_router.dart';
import 'package:signals/signals_flutter.dart';

final isAuthenticated = signal(false);

final counter = signal(0);

final queryClient = QueryClient(
  defaultQueryOptions: DefaultQueryOptions(),
);

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Future.delayed(const Duration(milliseconds: 2000), () {
    FlutterNativeSplash.remove();
  });
  runApp(QueryClientProvider(
    queryClient: queryClient,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isLoggedIn = isAuthenticated.value;

      return MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
              TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        routerConfig: GoRouter(
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const MyHomePage(title: 'Flutter Demo Home Page');
              },
              routes: <RouteBase>[
                GoRoute(
                  path: 'details',
                  builder: (BuildContext context, GoRouterState state) {
                    return const DetailsScreen();
                  },
                ),
              ],
              redirect: (BuildContext context, GoRouterState state) {
                if (!isLoggedIn) {
                  return '/login';
                } else {
                  return null;
                }
              },
            ),
            GoRoute(
              path: '/shope',
              builder: (BuildContext context, GoRouterState state) =>
                  const ShopeScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (BuildContext context, GoRouterState state) =>
                  const LoginScreen(),
              redirect: (BuildContext context, GoRouterState state) {
                if (isLoggedIn) {
                  return '/';
                } else {
                  return null;
                }
              },
            ),
          ],
        ),
        // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      );
    });
  }
}

Future<List<Todo>> getPosts() async {
  final res =
      await Dio().get('https://jsonplaceholder.typicode.com/todos?_limit=4');
  return (res.data as List)
      .map((e) => Todo.fromJson(e as Map<String, dynamic>))
      .toList();
}

class MyHomePage extends HookWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final counter = useState(0);
    final a = TodoRepositoryImpl();
    final todos = useQuery(['todos'], getPosts);

    log('data: ${todos.data}');

    void incrementCounter() {
      counter.value++;
    }

    if (todos.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

// An error has occurred
    if (todos.isError) {
      return Center(child: Text(todos.error!.toString()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${counter.value}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () => isAuthenticated.value = false,
              child: const Text('Log out'),
            ),
            ElevatedButton(
              onPressed: () => context.go('/shope'),
              child: const Text('Go to the shope screen'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todos.data!.length,
                itemBuilder: (context, index) {
                  final todo = todos.data![index];
                  return ListTile(
                    title: Text(todo.title!),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DetailsScreen extends StatelessWidget {
  /// Constructs a [DetailsScreen]
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go back to the Home screen'),
        ),
      ),
    );
  }
}

class ShopeScreen extends StatelessWidget {
  const ShopeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go back to the Home screen'),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go back to the Home screen'),
            ),
            ElevatedButton(
              onPressed: () => isAuthenticated.value = true,
              child: const Text('Login'),
            ),
            Watch(
              (context) => Text(
                '${counter.value}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('Count'),
            ),
          ],
        ),
      ),
    );
  }
}
