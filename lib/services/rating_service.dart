class RatingEntry {
  double buyRatingSum = 0;
  int buyCount = 0;
  double punctualitySum = 0;
  int punctualityCount = 0;

  double get buyRating => buyCount == 0 ? 0 : buyRatingSum / buyCount;
  double get punctuality => punctualityCount == 0 ? 0 : punctualitySum / punctualityCount;
}

class RatingService {
  RatingService._();
  static final RatingService instance = RatingService._();

  final Map<String, RatingEntry> _data = {};

  RatingEntry _entry(String user) => _data.putIfAbsent(user, () => RatingEntry());

  void recordPurchaseRating(String user, double stars) {
    final e = _entry(user);
    e.buyRatingSum += stars;
    e.buyCount += 1;
  }

  void recordPickup(String user, {required bool onTime, required String category}) {
    final e = _entry(user);
    e.punctualityCount += 1;
    e.punctualitySum += (onTime ? 5.0 : 1.0);

    // Top-picker logic: if category is scrap or e-waste, update top picker eligibility
    if (category.toLowerCase().contains('scrap') || category.toLowerCase().contains('e-waste')) {
      final onTimeSuccesses = _countRecentOnTime(user);
      if (onTimeSuccesses >= 3) {
        // enable top-picker in NotificationService
        // callers will set NotificationService.setTopPicker(user, true)
      }
    }
  }

  int _countRecentOnTime(String user) {
    final e = _data[user];
    if (e == null) return 0;
    // simplistic: return punctualityCount where we consider entries as on-time when punctualitySum high
    // For now return punctualityCount if average >=4.0
    final avg = e.punctuality;
    return avg >= 4.0 ? e.punctualityCount : 0;
  }

  double getBuyRating(String user) => _data[user]?.buyRating ?? 0;
  double getPunctuality(String user) => _data[user]?.punctuality ?? 0;
}
