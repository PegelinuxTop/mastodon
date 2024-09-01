import { forceGroupedNotifications } from 'flavours/glitch/initial_state';
import type { RootState } from 'flavours/glitch/store';

/* eslint-disable @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
// state.settings is not yet typed, so we disable some ESLint checks for those selectors
export const selectSettingsNotificationsShows = (state: RootState) =>
  state.settings.getIn(['notifications', 'shows']).toJS() as Record<
    string,
    boolean
  >;

export const selectSettingsNotificationsExcludedTypes = (state: RootState) =>
  Object.entries(selectSettingsNotificationsShows(state))
    .filter(([_type, enabled]) => !enabled)
    .map(([type, _enabled]) => type);

export const selectSettingsNotificationsQuickFilterShow = (state: RootState) =>
  state.settings.getIn(['notifications', 'quickFilter', 'show']) as boolean;

export const selectSettingsNotificationsQuickFilterActive = (
  state: RootState,
) => state.settings.getIn(['notifications', 'quickFilter', 'active']) as string;

export const selectSettingsNotificationsQuickFilterAdvanced = (
  state: RootState,
) =>
  state.settings.getIn(['notifications', 'quickFilter', 'advanced']) as boolean;

export const selectUseGroupedNotifications = (state: RootState) =>
  forceGroupedNotifications ||
  (state.settings.getIn(['notifications', 'groupingBeta']) as boolean);

export const selectSettingsNotificationsShowUnread = (state: RootState) =>
  state.settings.getIn(['notifications', 'showUnread']) as boolean;

export const selectNeedsNotificationPermission = (state: RootState) =>
  (state.settings.getIn(['notifications', 'alerts']).includes(true) &&
    state.notifications.get('browserSupport') &&
    state.notifications.get('browserPermission') === 'default' &&
    !state.settings.getIn([
      'notifications',
      'dismissPermissionBanner',
    ])) as boolean;

export const selectSettingsNotificationsMinimizeFilteredBanner = (
  state: RootState,
) =>
  state.settings.getIn(['notifications', 'minimizeFilteredBanner']) as boolean;

/* eslint-enable @typescript-eslint/no-unsafe-call, @typescript-eslint/no-unsafe-member-access */
