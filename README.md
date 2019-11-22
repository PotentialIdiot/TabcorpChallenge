# iOS Assignment

## Changelog
1. Improved readability of Table View classes using a more functional approach, inout, closures
2. Fixed filter bug and improved clarity via state machine
3. Improved performance of JSON payload using a generic function by only requesting attributes defined in the respective data models.  Works with any of the data model types e.g Launch, Rocket

## Notes
Performance can be further optimized by splitting Launch into two data models
- LaunchSimplified
- LaunchDetailed

* It would be cleaner to use two separate data models rather than a single Launch data model which implements  optional parameters and two CodingKey lists to compensate

* Using two data models would also be more memory efficient than a single Launch model

## General Info
An iOS app that displays data from spacex API
This project was initially developed using MVC, which was then converted to MVVM and RxSwift for the bonus points

MVVM is used to decouple the data formatting from the controllers and bind observables via RxSwift

## Assumptions
* Used static table view, iboutlets and storyboards for rapid development
* Limited server requests to 10 launches only
* Display a chosen few data points for launch and rocket as the detailed launch information screen instead of all the data in the endpoint

## Libraries
* RxSwift
