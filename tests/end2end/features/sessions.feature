Feature: Saving and loading sessions

  Background:
    Given I clean up open tabs

  Scenario: Saving a simple session
    When I open data/hello.txt
    And I open data/title.html in a new tab
    Then the session should look like:
      windows:
        - active: true
          tabs:
            - history:
              - url: about:blank
              - active: true
                url: http://localhost:*/data/hello.txt
            - active: true
              history:
              - active: true
                url: http://localhost:*/data/title.html
                title: Test title

  @qtwebengine_skip
  Scenario: Zooming (qtwebkit)
    When I open data/hello.txt
    And I run :zoom 50
    Then the session should look like:
      windows:
        - tabs:
          - history:
            - url: about:blank
              zoom: 1.0
            - url: http://localhost:*/data/hello.txt
              zoom: 0.5

  # The zoom level is only stored for the newest element for QtWebEngine.
  @qtwebkit_skip
  Scenario: Zooming (qtwebengine)
    When I open data/hello.txt
    And I run :zoom 50
    Then the session should look like:
      windows:
        - tabs:
          - history:
            - url: about:blank
            - url: http://localhost:*/data/hello.txt
              zoom: 0.5

  @qtwebengine_skip
  Scenario: Scrolling (qtwebkit)
    When I open data/scroll/simple.html
    And I run :scroll-px 10 20
    Then the session should look like:
      windows:
        - tabs:
          - history:
            - url: about:blank
              scroll-pos:
                x: 0
                y: 0
            - url: http://localhost:*/data/scroll/simple.html
              scroll-pos:
                x: 10
                y: 20

  # The scroll position is only stored for the newest element for QtWebEngine.
  @qtwebkit_skip
  Scenario: Scrolling (qtwebengine)
    When I open data/scroll/simple.html
    And I run :scroll-px 10 20
    And I wait for "Scroll position changed to PyQt5.QtCore.QPoint(10, 20)" in the log
    Then the session should look like:
      windows:
        - tabs:
          - history:
            - url: about:blank
            - url: http://localhost:*/data/scroll/simple.html
              scroll-pos:
                x: 10
                y: 20
  Scenario: Redirect
    When I open redirect-to?url=data/title.html without waiting
    And I wait until data/title.html is loaded
    Then the session should look like:
      windows:
        - tabs:
          - history:
            - url: about:blank
            - active: true
              url: http://localhost:*/data/title.html
              original-url: http://localhost:*/redirect-to?url=data/title.html
              title: Test title

  Scenario: Valid UTF-8 data
    When I open data/sessions/snowman.html
    Then the session should look like:
      windows:
      - tabs:
        - history:
          - url: about:blank
          - url: http://localhost:*/data/sessions/snowman.html
            title: snow☃man

  @qtwebengine_skip
  Scenario: Long output comparison (qtwebkit)
    When I open data/numbers/1.txt
    And I open data/title.html
    And I open data/numbers/2.txt in a new tab
    And I open data/numbers/3.txt in a new window
    # Full output apart from "geometry:"
    Then the session should look like:
      windows:
      - active: true
        tabs:
        - history:
          - scroll-pos:
              x: 0
              y: 0
            title: about:blank
            url: about:blank
            zoom: 1.0
          - scroll-pos:
              x: 0
              y: 0
            title: http://localhost:*/data/numbers/1.txt
            url: http://localhost:*/data/numbers/1.txt
            zoom: 1.0
          - active: true
            scroll-pos:
              x: 0
              y: 0
            title: Test title
            url: http://localhost:*/data/title.html
            zoom: 1.0
        - active: true
          history:
          - active: true
            scroll-pos:
              x: 0
              y: 0
            title: ''
            url: http://localhost:*/data/numbers/2.txt
            zoom: 1.0
      - tabs:
        - active: true
          history:
          - active: true
            scroll-pos:
              x: 0
              y: 0
            title: ''
            url: http://localhost:*/data/numbers/3.txt
            zoom: 1.0

  # FIXME:qtwebengine what's up with the titles there?
  @qtwebkit_skip
  Scenario: Long output comparison (qtwebengine)
    When I open data/numbers/1.txt
    And I open data/title.html
    And I open data/numbers/2.txt in a new tab
    And I open data/numbers/3.txt in a new window
    # Full output apart from "geometry:"
    Then the session should look like:
      windows:
      - active: true
        tabs:
        - history:
          - title: about:blank
            url: about:blank
          - title: http://localhost:*/data/numbers/1.txt
            url: http://localhost:*/data/numbers/1.txt
          - active: true
            scroll-pos:
              x: 0
              y: 0
            title: Test title
            url: http://localhost:*/data/title.html
            zoom: 1.0
        - active: true
          history:
          - active: true
            scroll-pos:
              x: 0
              y: 0
            title: localhost:*/data/numbers/2.txt
            url: http://localhost:*/data/numbers/2.txt
            zoom: 1.0
      - tabs:
        - active: true
          history:
          - active: true
            scroll-pos:
              x: 0
              y: 0
            title: localhost:*/data/numbers/3.txt
            url: http://localhost:*/data/numbers/3.txt
            zoom: 1.0

  # https://github.com/The-Compiler/qutebrowser/issues/879

  Scenario: Saving a session with a page using history.replaceState()
    When I open data/sessions/history_replace_state.html without waiting
    Then the javascript message "Calling history.replaceState" should be logged
    And the session should look like:
      windows:
      - tabs:
        - history:
          - url: about:blank
          - active: true
            url: http://localhost:*/data/sessions/history_replace_state.html?state=2
            title: Test title

  @qtwebengine_skip
  Scenario: Saving a session with a page using history.replaceState() and navigating away (qtwebkit)
    When I open data/sessions/history_replace_state.html
    And I open data/hello.txt
    Then the javascript message "Calling history.replaceState" should be logged
    And the session should look like:
      windows:
      - tabs:
        - history:
          - url: about:blank
          - url: http://localhost:*/data/sessions/history_replace_state.html?state=2
            # What we'd *really* expect here is "Test title", but that
            # workaround is the best we can do.
            title: http://localhost:*/data/sessions/history_replace_state.html?state=2
          - active: true
            url: http://localhost:*/data/hello.txt

  # Seems like that bug is fixed upstream in QtWebEngine
  @qtwebkit_skip
  Scenario: Saving a session with a page using history.replaceState() and navigating away
    When I open data/sessions/history_replace_state.html without waiting
    And I wait for "* Calling history.replaceState" in the log
    And I open data/hello.txt
    Then the session should look like:
      windows:
      - tabs:
        - history:
          - url: about:blank
          - url: http://localhost:*/data/sessions/history_replace_state.html?state=2
            title: Test title
          - active: true
            url: http://localhost:*/data/hello.txt

  # :session-save

  Scenario: Saving to a directory
    When I run :session-save (tmpdir)
    Then the error "Error while saving session: *" should be shown

  Scenario: Saving internal session without --force
    When I run :session-save _internal
    Then the error "_internal is an internal session, use --force to save anyways." should be shown
    And the session _internal should not exist

  Scenario: Saving internal session with --force
    When I run :session-save --force _internal_force
    Then the message "Saved session _internal_force." should be shown
    And the session _internal_force should exist

  Scenario: Saving current session without one loaded
    Given I have a fresh instance
    And I run :session-save --current
    Then the error "No session loaded currently!" should be shown

  Scenario: Saving current session after one is loaded
    When I run :session-save current_session
    And I run :session-load current_session
    And I run :session-save --current
    Then the message "Saved session current_session." should be shown

  Scenario: Saving session
    When I run :session-save session_name
    Then the message "Saved session session_name." should be shown
    And the session session_name should exist

  Scenario: Saving session with --quiet
    When I run :session-save --quiet quiet_session
    Then "Saved session quiet_session." should not be logged
    And the session quiet_session should exist

  # :session-delete

  Scenario: Deleting a directory
    When I run :session-delete (tmpdir)
    Then "Error while deleting session!" should be logged
    And the error "Error while deleting session: *" should be shown

  Scenario: Deleting internal session without --force
    When I run :session-save --force _internal
    And I run :session-delete _internal
    Then the error "_internal is an internal session, use --force to delete anyways." should be shown
    And the session _internal should exist

  Scenario: Deleting internal session with --force
    When I run :session-save --force _internal
    And I run :session-delete --force _internal
    Then the session _internal should not exist

  Scenario: Normally deleting a session
    When I run :session-save deleted_session
    And I run :session-delete deleted_session
    Then the session deleted_session should not exist

  Scenario: Deleting a session which doesn't exist
    When I run :session-delete inexistent_session
    Then the error "Session inexistent_session not found!" should be shown

  # :session-load

  Scenario: Loading a directory
    When I run :session-load (tmpdir)
    Then the error "Error while loading session: *" should be shown
    
  Scenario: Loading internal session without --force
    When I run :session-save --force _internal
    And I run :session-load _internal
    Then the error "_internal is an internal session, use --force to load anyways." should be shown

  Scenario: Loading internal session with --force
    When I open about:blank
    And I run :session-save --force _internal
    And I replace "about:blank" by "http://localhost:(port)/data/numbers/1.txt" in the "_internal" session file
    And I run :session-load --force _internal
    Then data/numbers/1.txt should be loaded

  Scenario: Normally loading a session
    When I open about:blank
    And I run :session-save loaded_session
    And I replace "about:blank" by "http://localhost:(port)/data/numbers/2.txt" in the "loaded_session" session file
    And I run :session-load loaded_session
    Then data/numbers/2.txt should be loaded

  Scenario: Loading a session which doesn't exist
    When I run :session-load inexistent_session
    Then the error "Session inexistent_session not found!" should be shown
