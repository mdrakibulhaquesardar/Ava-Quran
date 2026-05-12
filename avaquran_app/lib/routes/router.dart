import '/resources/pages/video_feed_page.dart';
import '/resources/pages/blogs_page.dart';
import '/resources/pages/videos_page.dart';
import '/resources/pages/peoples_page.dart';
import '/resources/pages/feed_page.dart';
import '/resources/pages/auth_page.dart';
import '/resources/pages/onboarding_page.dart';
import '/resources/pages/not_found_page.dart';
import '/resources/pages/home_page.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* App Router
|--------------------------------------------------------------------------
| * [Tip] Create pages faster 🚀
| Terminal: "metro make:page profile_page"

| Learn more https://nylo.dev/docs/7.x/router
|-------------------------------------------------------------------------- */

appRouter() => nyRoutes((router) {
      router.add(HomePage.path);

      router.add(NotFoundPage.path).unknownRoute();
      router.add(OnboardingPage.path).initialRoute();
      router.add(AuthPage.path);
      router.add(FeedPage.path);
      router.add(PeoplesPage.path);
      router.add(VideosPage.path);
      router.add(BlogsPage.path);
      router.add(VideoFeedPage.path);
});
