//
//  FIRService.swift
//  Project2-PMS
//
//  Created by Mark on 1/23/18.
//  Copyright © 2018 RJTCompuquest. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class FIRService: NSObject {
    enum FIRServiceError: Error {
        case pathNotFoundInDatabase
        case noUserLoggedIn
        case taskDoesNotExist
		case failParseProjectInfo
    }
	
	typealias LoginResultHandler = (User?, Error?) -> ()
	typealias FetchProjectResultHandler = (Project?, Error?) -> ()
	typealias FetchProjectsResultHandler = ([Project]?, Error?) -> ()
	
	static let shareInstance = FIRService()
	
	// Database refences
	private var userRef: DatabaseReference!
	private var databaseRef : DatabaseReference!
	private var storageRef: StorageReference!
	
	private override init() {
		userRef = Database.database().reference().child("Users")
		databaseRef = Database.database().reference()
		storageRef = Storage.storage().reference()
	}
    
	
	// create user profile in DB
    func createUserProfile(ofUser uid: String, name: String?, email: String?, role: String?) {
        let userDict = ["name": name, "email": email, "role": role]
		databaseRef.child("Users").child(uid).updateChildValues(userDict)
	}
    
    func createOrDeleteTask(task: Task, toCreate: Bool, completion: @escaping (Error?) -> ()) {
        guard let userId = CurrentUser.sharedInstance.userId else {
            completion(FIRServiceError.noUserLoggedIn)
            return
        }
        
        // create task and add to "Tasks" table
        let key = databaseRef.child("Tasks").childByAutoId().key
//        let timestamp = (Date().timeIntervalSince1970)
        
        let taskDict = ["title": task.title, "description": task.description, "start date": task.startDate?.timeIntervalSince1970, "due date": task.dueDate?.timeIntervalSince1970, "projectID": task.projectId, "isCompleted": false] as [String : Any]
        databaseRef.child("Tasks").child(key).updateChildValues(taskDict)
        completion(nil)
    }
	
    
    func getTaskInfo(ofTask id: String, completion: @escaping (Task?, Error?) -> ()) {
        let ref = databaseRef.child("Tasks").child(id)
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var taskDict : [String: Any]
            taskDict = snapshot.value as? [String: Any] ?? [:]
            let task = Task(id: id)
            task.title = taskDict["title"] as? String
            task.description = taskDict["description"] as? String
            if let startTimestamp = taskDict["start date"] as? TimeInterval{
                task.startDate = Date(timeIntervalSince1970: startTimestamp)
            }
            if let dueTimestamp = taskDict["due date"] as? TimeInterval {
                task.dueDate = Date(timeIntervalSince1970: dueTimestamp)
            }
            
            task.members = []
            if let members = taskDict["members"] as? [String: Any] {
                let memberIds = Array(members.keys)
                for memberId in memberIds {
                    task.members?.append(Member(id: memberId))
                }
            }
            
            task.isCompleted = taskDict["isCompleted"] as? Bool
            task.projectId = taskDict["projectID"] as? String
            
            completion(task, nil)
        })
    }
    
    
    func getAllTaskIds(ofUser uid: String, completion: @escaping ([String]?, Error?) -> ()) {
        let ref = databaseRef.child("Users").child(uid).child("tasks")
        ref.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            var taskDict : [String: Any]
            taskDict = snapshot.value as? [String: Any] ?? [:]
            let tasks : [String] = Array(taskDict.keys)
            completion(tasks, nil)
        })
    }
	
	// Email,Password login
	func loginUser(with email: String, and password: String, completion: @escaping LoginResultHandler) {
		Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
			DispatchQueue.main.async {
				completion(user, error)
			}
		}
	}
	
	// OAuth Login
	func loginUser(with credential: AuthCredential, completion: @escaping LoginResultHandler) {
		Auth.auth().signIn(with: credential) { (user, error) in
			DispatchQueue.main.async {
				completion(user, error)
			}
		}
	}
	
	// Save loggedin user info in Firebase Users table and store into as CurrentUser singleton
	func saveLoggedInUser(_ user: User, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		
		userRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
			if !snapshot.hasChild(user.uid) {
				// If record not exist, create one (only for OAuth)
				self?.userRef.child(user.uid).updateChildValues(
					["name": user.displayName ?? "",
					 "email": user.email!,
					 "profile photo": user.photoURL?.absoluteString ?? ""
					]
				)
				// save oAuth user info to current user
				currentUser.update(id: user.uid,
								   email: user.email!,
								   name: user.displayName!,
								   photoUrl: user.photoURL,
								   role: .none)
				currentUser.save()
				
				DispatchQueue.main.async {
					completion()
				}
			} else {
				// if record exist, fetch it
				self?.fetchCurrentUserInfo(with: user.uid) {
					DispatchQueue.main.async {
						completion()
					}
				}
			}
		}
	}
	
	// Fetch currentuser info from firebase and store in singleton
	func fetchCurrentUserInfo(with id: String, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		
		userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
			if let userDict = snapshot.value as? [String: String],
				let email = userDict["email"],
				let name = userDict["name"] {
				
				// handle situation when user login Oauth but close app in choose role page
				var role: Role!
				if userDict["role"] == nil {
					role = Role.none
				} else {
					role = Role(rawValue: userDict["role"]!)
				}
				
				var photoUrl: URL?
				if let profileUrlStr = userDict["profile photo"] {
					photoUrl = URL(string: profileUrlStr)
				}
				
				currentUser.update(id: id,
								   email: email,
								   name: name,
								   photoUrl: photoUrl,
								   role: role)
				currentUser.save()
				
				DispatchQueue.main.async {
					completion()
				}
			}
		}
	}
	
	// fetch all projects for manager
	func getAllProjects(with managerId: String, completion: @escaping FetchProjectsResultHandler) {
		let fetchProjectIdsGroup = DispatchGroup()
		let fetchProjectGroup = DispatchGroup()
		var error: Error?
		var projectIds: [String] = []
		var projectResults: [Project] = []
		
		fetchProjectIdsGroup.enter()
		getProjectIds(with: managerId) { (pIds, err) in
			fetchProjectIdsGroup.leave()
			guard error == nil, let unwrappedIds = pIds else {
				error = err
				completion(nil, error)
				return
			}
			projectIds = unwrappedIds
		}
		
		fetchProjectIdsGroup.notify(queue: .main) { [weak self] in
			for projectId in projectIds {
				fetchProjectGroup.enter()
				self?.getProjectInfo(with: projectId) { (project, err) in
					fetchProjectGroup.leave()
					guard error == nil, let unwrappedProject = project else {
						error = err
						completion(nil, error)
						return
					}
					projectResults.append(unwrappedProject)
				}
			}
			
			fetchProjectGroup.notify(queue: .main) {
				completion(projectResults.isEmpty ? nil : projectResults, error)
			}
		}
	}
	
	// find projects Ids associated with a user
	private func getProjectIds(with userId: String, completion: @escaping ([String]?, Error?) -> ()) {
		let ref = databaseRef.child("Users").child(userId).child("projects")
		ref.observeSingleEvent(of: .value){ (snapshot) in
			if let pIdDict = snapshot.value as? [String: Any] {
				let projectIds = Array(pIdDict.keys)
				completion(projectIds, nil)
			} else {
				completion(nil, FIRServiceError.pathNotFoundInDatabase)
			}
		}
	}
	
	// fetch projects for a member
	func getMemberProjects(with userId: String, completion: @escaping FetchProjectsResultHandler) {
		// key: project id, value: array of tasks Id current user is working on
		let getAllTaskIdsGroup = DispatchGroup()
		let getProjectIdsGroup = DispatchGroup()
		let getProjectsGroup = DispatchGroup()
		var projectResults: [Project] = []
		var taskIds: [String] = []
		var projectIds: [String] = []
		var error: Error?
		
		// fetch all tasks ids for this user
		getAllTaskIdsGroup.enter()
		getAllTaskIds(ofUser: userId) { (ids, err) in
			getAllTaskIdsGroup.leave()
			guard error == nil, let unwrappedIds = ids else {
				error = err
				return
			}
			taskIds = unwrappedIds
		}
		
		getAllTaskIdsGroup.notify(queue: .main) { [weak self] in
			// for each task we find it's associated project
			getProjectIdsGroup.enter()
			self?.getProjectIds(with: userId) { (pIds, err) in
				getProjectIdsGroup.leave()
				guard error == nil, let unwrappedIds = pIds else {
					error = err
					return
				}
				projectIds = unwrappedIds
			}
			
			getProjectIdsGroup.notify(queue: .main) { [weak self] in
				for projectId in projectIds {
					getProjectsGroup.enter()
					self?.getProjectInfo(with: projectId, filteredAgainst: taskIds) { (project, err) in
						getProjectsGroup.leave()
						guard error == nil, let unwrappedProject = project else {
							error = err
							return
						}
						projectResults.append(unwrappedProject)
					}
				}
				
				getProjectsGroup.notify(queue: .main) {
					// complete!
					completion(projectResults.isEmpty ? nil : projectResults, error)
				}
			}
		}
	}
	
	/**
		Note: when filteredAgainst is nil, fetch single project data with all the fields
		when filtedAgainst is provided, fetch a single project with only taks ids that is in filtedAgainst
	*/
	func getProjectInfo(with projectId: String, filteredAgainst taskIds: [String]? = nil, completion: @escaping FetchProjectResultHandler) {
		let projectRef = databaseRef.child("Projects")
		
		projectRef.child(projectId).observeSingleEvent(of: .value) { (snapshot) in
			if let projectDict = snapshot.value as? [String: Any],
				let description = projectDict["description"] as? String,
				let dueDate = projectDict["due date"] as? TimeInterval,
				let startDate = projectDict["start date"] as? TimeInterval,
				let name = projectDict["name"] as? String,
				let managerId = projectDict["manager"] as? String {
				
				var project = Project(id: projectId,
									  description: description,
									  startDate: Date(timeIntervalSince1970: startDate),
									  endDate: Date(timeIntervalSince1970: dueDate),
									  name: name,
									  tasks: [],
									  members: [],
									  managerId: managerId)
				
				if let memberDict = projectDict["members"] as? [String: Any] {
					let memberIds = Array(memberDict.keys)
					for id in memberIds {
						project.members!.append(Member(id: id))
					}
				}
				
				if let taskDict = projectDict["task"] as? [String: Any] {
					
					// filter only the taskIds that is in memeber's tasks list if taskIds is not nil
					let projectTaskIds = taskIds == nil ?
						Array(taskDict.keys) :
						Array(taskDict.keys).filter { taskIds!.contains($0) }
					
					for id in projectTaskIds {
						project.tasks!.append(Task(id: id))
					}
				}
				
				completion(project, nil)
			} else {
				completion(nil, FIRServiceError.failParseProjectInfo)
			}
		}
	}
	
	// Create Project
	func createProject(for project: Project, completion: @escaping () -> ()) {
		let currentUser = CurrentUser.sharedInstance
		let newProjectRef = databaseRef.child("Projects").child(project.id)
		
		// create new project
		let projectDict = ["name": project.name,
						   "description": project.description,
						   "manager": currentUser.userId,
						   "start date": project.startDate.timeIntervalSince1970,
						   "due date": project.endDate.timeIntervalSince1970] as [String: Any]
		
		
		newProjectRef.updateChildValues(projectDict)
		
		// update manager's project list
		userRef.child(currentUser.userId).child("projects").updateChildValues([project.id: true])
		
		completion()
	}
}
