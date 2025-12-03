import 'package:flutter/material.dart';
import '../../core/core.dart';
import '../../data/data.dart';
import '../controllers/controllers.dart';
import '../controllers/storage_controller.dart';

/// InheritedNotifier wrapper for AuthController
class AuthProvider extends InheritedNotifier<AuthController> {
  const AuthProvider({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    assert(provider != null, 'No AuthProvider found in context');
    return provider!.notifier!;
  }

  static AuthController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AuthProvider>();
    return provider?.notifier;
  }
}

/// InheritedNotifier wrapper for PostsController
class PostsProvider extends InheritedNotifier<PostsController> {
  const PostsProvider({
    super.key,
    required PostsController controller,
    required super.child,
  }) : super(notifier: controller);

  static PostsController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PostsProvider>();
    assert(provider != null, 'No PostsProvider found in context');
    return provider!.notifier!;
  }

  static PostsController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<PostsProvider>();
    return provider?.notifier;
  }
}

/// InheritedNotifier wrapper for CommentsController
class CommentsProvider extends InheritedNotifier<CommentsController> {
  const CommentsProvider({
    super.key,
    required CommentsController controller,
    required super.child,
  }) : super(notifier: controller);

  static CommentsController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CommentsProvider>();
    assert(provider != null, 'No CommentsProvider found in context');
    return provider!.notifier!;
  }

  static CommentsController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CommentsProvider>();
    return provider?.notifier;
  }
}

/// InheritedNotifier wrapper for StorageController
class StorageProvider extends InheritedNotifier<StorageController> {
  const StorageProvider({
    super.key,
    required StorageController controller,
    required super.child,
  }) : super(notifier: controller);

  static StorageController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StorageProvider>();
    assert(provider != null, 'No StorageProvider found in context');
    return provider!.notifier!;
  }

  static StorageController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<StorageProvider>();
    return provider?.notifier;
  }
}

/// App providers composition root
class AppProviders extends StatefulWidget {
  final Widget child;
  final String? baseUrl;

  const AppProviders({
    super.key,
    required this.child,
    this.baseUrl,
  });

  @override
  State<AppProviders> createState() => _AppProvidersState();
}

class _AppProvidersState extends State<AppProviders> {
  late final ApiClient _apiClient;
  late final StorageService _storageService;
  late final CacheDataSource _cacheDataSource;

  late final AuthRemoteDataSourceImpl _authRemoteDataSource;
  late final PostsRemoteDataSourceImpl _postsRemoteDataSource;
  late final CommentsRemoteDataSourceImpl _commentsRemoteDataSource;

  late final AuthRepositoryImpl _authRepository;
  late final PostsRepositoryImpl _postsRepository;
  late final CommentsRepositoryImpl _commentsRepository;

  late final AuthController _authController;
  late final PostsController _postsController;
  late final CommentsController _commentsController;
  late final StorageController _storageController;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
  }

  Future<void> _initializeDependencies() async {
    // Core services
    _apiClient = ApiClient(baseUrl: widget.baseUrl);
    _storageService = StorageService();
    await _storageService.init();
    _cacheDataSource = CacheDataSource(_storageService);

    // Restore token if available
    final token = _storageService.getToken();
    if (token != null) {
      _apiClient.setToken(token);
    }

    // Data sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_apiClient);
    _postsRemoteDataSource = PostsRemoteDataSourceImpl(_apiClient);
    _commentsRemoteDataSource = CommentsRemoteDataSourceImpl(_apiClient);

    // Repositories
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authRemoteDataSource,
      storageService: _storageService,
      cacheDataSource: _cacheDataSource,
      apiClient: _apiClient,
    );
    _postsRepository = PostsRepositoryImpl(
      remoteDataSource: _postsRemoteDataSource,
      cacheDataSource: _cacheDataSource,
    );
    _commentsRepository = CommentsRepositoryImpl(
      remoteDataSource: _commentsRemoteDataSource,
    );

    // Controllers
    _authController = AuthController(_authRepository);
    _postsController = PostsController(_postsRepository);
    _commentsController = CommentsController(_commentsRepository);
    _storageController = StorageController(StorageRepositoryImpl(remoteDataSource: StorageRemoteDataSourceImpl(_apiClient)));

    // Initialize auth state
    await _authController.init();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _authController.dispose();
    _postsController.dispose();
    _commentsController.dispose();
    _apiClient.dispose();
    _storageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return AuthProvider(
      controller: _authController,
      child: PostsProvider(
        controller: _postsController,
        child: CommentsProvider(
          controller: _commentsController,
          child: StorageProvider(
            controller: _storageController,
            child: Builder(
              builder: (context) => widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
