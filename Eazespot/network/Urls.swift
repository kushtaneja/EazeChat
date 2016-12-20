
import Foundation

class Urls {
    
    var serverUrlV1 = "https://api.eazespot.com/v1/"
    var serverUrl = "https://api.eazespot.com/"
    
    func login() -> String{
        return "\(serverUrlV1)login/"
    }
    
    func getProfile(company_id: String, user_id: String ) -> String {
        return "\(serverUrlV1)company/\(company_id)/user/\(user_id)/"
    }
    
    func forgotPassword()->String{
        return "\(serverUrlV1)forgetpassword/"
    }
    
    
    
    
    
    
    func signUp() -> String{
        return "\(serverUrlV1)users/"
    }
    
    
    
    func socialLogin() -> String{
        return"\(serverUrlV1)social/signin/"
    }
    
    func fetchLoggedInUserData(_ id: String)->String{
        return "\(serverUrlV1)users/\(id)/"
    }
    
    func getFoodItemDetails(_ id: String)->String{
        return "\(serverUrlV1)food/\(id)"
    }
    
    func imageUploadURL()->String{
        return "\(serverUrlV1)uploads/"
    }
    
    func logItems()->String {
        return "\(serverUrlV1)logger/"
    }
    
    func refreshFoodItem()->String{
        return "\(serverUrlV1)automation/getdiet/replace/"
    }
    
    func addFoodItemToFavourite()->String{
        return "\(serverUrlV1)recipe/like"
    }
    
    func removeFoodItemFromFavourite()->String{
        return "\(serverUrlV1)recipe/unlike"
    }
    
    func logWater()->String {
        return "\(serverUrlV1)logger/water/mass/"
    }
    
    func logSleep()->String {
        return "\(serverUrlV1)logger/sleep/mass/"
    }
    
    func categoryLogHistoryOfParticularDay()->String {
        return "\(serverUrlV1)logger/history/"
    }
    
    func sleepLogHistoryOfParticularDay()->String {
        return "\(serverUrlV1)logger/sleep/"
    }
    
    func caloriesLogHistoryOfParticularDay()->String {
        return "\(serverUrlV1)users/energy/"
    }
    
    func userLogHistoryOfDateRange()->String {
        return "\(serverUrlV1)users/history/"
    }
    
    func fetchPeopleConnectProfileData()->String{
        return "\(serverUrlV1)connect/profile/"
    }
    
    func getAllInterestsList()->String{
        return "\(serverUrlV1)interest/list/"
    }
    
    func getUserInterests()->String{
        return "\(serverUrlV1)interest/"
    }
    
    func getUsersNearby()->String{
        return "\(serverUrlV1)users/nearby/custom/"
    }
    
    func connectUser()->String{
        return "\(serverUrlV1)users/connect/"
    }
    
    func saveUserInterests()->String{
        return "\(serverUrlV1)interest/mass/"
    }
    
    func getSettingsValues()->String{
        return "\(serverUrlV1)users/settings/"
    }
    
    
    func getAllSetMyGoalsList()->String{
        return "\(serverUrlV1)goals/"
    }
    
    func getAllDietPreferenceList()->String{
        return "\(serverUrlV1)diet_pref/"
    }
    
    
    func getPeopleConnectDataFromFacebook()->String{
        return "\(serverUrlV1)connect/"
    }
    
    
    func suggestInterest()->String{
        return "\(serverUrlV1)interest/create/"
    }
    
    func getAllCuisines()->String{
        return "\(serverUrlV1)cuisines/"
    }
    
    
    func getMyEventsList()->String{
        return "\(serverUrlV1)events/"
    }
    
    func editMyEvent(_ id: String)->String{
        return "\(serverUrlV1)events/\(id)/"
    }
    
    func getAllEventsList()->String{
        return "\(serverUrlV1)events/location/"
    }
    
    func searchEventType()->String{
        return "\(serverUrlV1)eventtype/search/"
    }
    
    func sendJoinRequestToEvent()->String{
        return "\(serverUrlV1)events/join/"
    }
    
    func archiveEvent()->String{
        return "\(serverUrlV1)events/archive/"
    }
    
    func userRequestsForEvent(_ id: String)->String{
        return "\(serverUrlV1)events/\(id)/users/"
    }
    
    func sendUserCarrier()->String{
        return "\(serverUrlV1)users/carrier/"
    }
    
    func getExerciseItemDetails(_ id: String)->String{
        return "\(serverUrlV1)exercise/\(id)"
    }
    
    func foodElasticSearch()->String{
        return "\(serverUrlV1)elastic_search/recipe_search"
    }
    
    func exerciseElasticSearch()->String{
        return "\(serverUrlV1)elastic_search/exercise_search"
    }

    func editLoggedItem(_ id: String)->String{
        return "\(serverUrlV1)logger/\(id)/"
    }
    
    func logFeeling()->String {
        return "\(serverUrlV1)logger/feeling/mass/"
    }
    
    func getLoggedFeeling()->String {
        return "\(serverUrlV1)logger/feeling/"
    }
    
    
    func getFoodRecommendations()->String {
        return "\(serverUrlV1)users/diet/day/"
    }
    
    func getNutritionistChatUser()->String {
        return "\(serverUrlV1)users/nutritionist/"
    }
    
    
    func suggestFood()->String{
        return "\(serverUrlV1)food/create/"
    }
    
    func suggestExercise()->String{
        return "\(serverUrlV1)exercise/create/"
    }
    
    
    func getTrackMyWeight()->String{
        return "\(serverUrlV1)graphs/weight_graph/"
    }
    
    
    func phoneNumberVerification()->String{
        return "\(serverUrlV1)phone/verification/"
    }
    
    
    func getUserChatCredentials()->String{
        return "\(serverUrlV1)users/chat/"
    }
    
}

