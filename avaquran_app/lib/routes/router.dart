import '/resources/pages/support_feedback_page.dart';
import '/resources/pages/privacy_security_page.dart';
import '/resources/pages/prayer_notifications_page.dart';
import '/resources/pages/app_appearance_page.dart';
import '/resources/pages/account_info_page.dart';
import '/resources/pages/create_blog_page.dart';
import '/resources/pages/collections_page.dart';
import '/resources/pages/quran_auth_page.dart';
import '/resources/pages/blog_details_page.dart';
import '/resources/pages/profile_page.dart';
import '/resources/pages/video_feed_page.dart';
import '/resources/pages/blogs_page.dart';
import '/resources/pages/videos_page.dart';
import '/resources/pages/peoples_page.dart';
import '/resources/pages/feed_page.dart';
import '/resources/pages/auth_page.dart';
import '/resources/pages/onboarding_page.dart';
import '/resources/pages/not_found_page.dart';
import '/resources/pages/home_page.dart';
import '/resources/pages/tafsir_list_page.dart';
import '/resources/pages/tafsir_details_page.dart';
import '/resources/pages/mushaf_page.dart';
import '/resources/pages/audio_player_page.dart';
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
  router.add(ProfilePage.path);
  router.add(BlogDetailsPage.path);
  router.add(QuranAuthPage.path);
  router.add(CreateBlogPage.path);
  router.add(CollectionsPage.path);
  router.add(AccountInfoPage.path);
  router.add(AppAppearancePage.path);
  router.add(PrayerNotificationsPage.path);
  router.add(PrivacySecurityPage.path);
  router.add(SupportFeedbackPage.path);
  router.add(TafsirListPage.path);
  router.add(TafsirDetailsPage.path);
  router.add(MushafPage.path);
  router.add(AudioPlayerPage.path);
});
