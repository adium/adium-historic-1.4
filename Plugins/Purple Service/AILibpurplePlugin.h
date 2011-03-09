
@protocol AILibpurplePlugin <AIPlugin>
/*!
 * @brief Perform early libpurple-specific installation of the plugin. 
 *
 * There is no guarantee what else is loaded at this point besides core functionality. 
 * See loadLibpurplePlugin to connct to other components' signals and such.
 */
- (void)installLibpurplePlugin;

/*!
 * @brief Once libpurple itself is ready, load the plugin
 */
- (void)loadLibpurplePlugin;
@end

/*!
 * @brief Notification that libpurple did initialize.
 *
 * Posted on NSNotificationCenter's defaultCenter.
 *
 * All plugins which are going to be loaded will be loaded before this is posted.
 */
#define AILibpurpleDidInitialize @"AILibpurpleDidInitialize"
