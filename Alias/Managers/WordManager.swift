import Foundation

/// Manages word loading and dictionary operations
struct WordManager {

    /// Loads words from a dictionary, now language-aware
    static func loadWords(from dictionary: WordDictionary) -> [String] {
        // For built-in dictionaries, generate language-specific words
        // For custom dictionaries (ID > 100), load from disk
        let languageCode = SettingsManager.shared.selectedLanguage.rawValue

        switch dictionary.id {
        case 0: // Easy
            return generateDefaultWords(language: languageCode, difficulty: .easy, count: DictionaryDefaults.easyWordCount)
        case 1: // Medium
            return generateDefaultWords(language: languageCode, difficulty: .medium, count: DictionaryDefaults.mediumWordCount)
        case 2: // Hard
            return generateDefaultWords(language: languageCode, difficulty: .hard, count: DictionaryDefaults.hardWordCount)
        default: // Custom dictionary - load from disk
            if let customWords = loadCustomDictionary(id: dictionary.id) {
                return customWords
            }
            // Fallback to English medium if file not found
            return generateDefaultWords(language: "en", difficulty: .medium, count: max(120, dictionary.wordCount))
        }
    }

    /// Loads a custom dictionary from disk by ID
    private static func loadCustomDictionary(id: Int) -> [String]? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let customDictDirectory = documentsDirectory.appendingPathComponent("CustomDictionaries")
        let fileName = "\(id).txt"
        let fileURL = customDictDirectory.appendingPathComponent(fileName)

        // Try to read the file
        guard let content = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return nil
        }

        // Preserve generated short phrases; the game display supports them.
        let words = content
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return words
    }

    /// Removes duplicates and normalizes words
    static func normalizeWords(_ words: [String]) -> [String] {
        // Remove duplicates, lowercase, and trim
        let normalized = words.map { word in
            word.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .folding(options: .diacriticInsensitive, locale: .current)
        }

        // Remove duplicates while preserving original casing
        var seen = Set<String>()
        var unique: [String] = []

        for (index, normalizedWord) in normalized.enumerated() {
            if !seen.contains(normalizedWord) {
                seen.insert(normalizedWord)
                unique.append(words[index])
            }
        }

        return unique
    }

    /// Distributes words evenly among players
    static func distributeWords(_ words: [String], playerCount: Int) -> [[String]] {
        guard playerCount > 0 else { return [] }

        let normalized = normalizeWords(words)
        let shuffled = normalized.shuffled()
        let wordsPerPlayer = shuffled.count / playerCount

        var playerPools: [[String]] = []

        for i in 0..<playerCount {
            let startIndex = i * wordsPerPlayer
            let endIndex = i == playerCount - 1 ? shuffled.count : (i + 1) * wordsPerPlayer
            let pool = Array(shuffled[startIndex..<endIndex])
            playerPools.append(pool)
        }

        return playerPools
    }

    // MARK: - Default Word Generation (Corrected)

    private enum Difficulty {
        case easy, medium, hard
    }

    /// Generates default words based on language and difficulty.
    private static func generateDefaultWords(language: String, difficulty: Difficulty, count: Int) -> [String] {
        let wordList: [String]
        
        switch language {
        case "uk":
            switch difficulty {
            case .easy: wordList = ukrainianEasyWords
            case .medium: wordList = ukrainianMediumWords
            case .hard: wordList = ukrainianHardWords
            }
        case "ru":
            switch difficulty {
            case .easy: wordList = russianEasyWords
            case .medium: wordList = russianMediumWords
            case .hard: wordList = russianHardWords
            }
        default: // English (en) is the fallback
            switch difficulty {
            case .easy: wordList = englishEasyWords
            case .medium: wordList = englishMediumWords
            case .hard: wordList = englishHardWords
            }
        }
        
        // Shuffle the list and take the required number of words to ensure variety
        return Array(wordList.shuffled().prefix(count))
    }

        // MARK: - 🇬🇧 English Word Lists
        private static let englishEasyWords = [
            "Sun", "Moon", "Star", "Cloud", "Rain", "Snow", "Wind", "Tree", "Flower", "Grass", "River", "Ocean",
            "Mountain", "House", "Door", "Window", "Chair", "Table", "Bed", "Book", "Pen", "Paper", "Phone", "Key",
            "Car", "Road", "Bridge", "Boat", "Train", "Plane", "Cat", "Dog", "Bird", "Fish", "Lion", "Tiger", "Bear",
            "Apple", "Banana", "Orange", "Bread", "Cheese", "Water", "Milk", "Coffee", "Tea", "Juice", "Hand", "Foot",
            "Eye", "Nose", "Mouth", "Ear", "Hair", "Smile", "Cry", "Laugh", "Run", "Walk", "Jump", "Swim", "Sing",
            "Dance", "Read", "Write", "Sleep", "Eat", "Drink", "Play", "Work", "Happy", "Sad", "Big", "Small", "Hot",
            "Cold", "Red", "Blue", "Green", "Yellow", "Ball", "Box", "Clock", "Lamp", "Shoe", "Hat", "Shirt", "Time",
            "Person", "Year", "Way", "Day", "Thing", "Man", "World", "Life", "Part", "Child", "Woman", "Place",
            "Week", "Case", "Point", "Government", "Company", "Number", "Group", "Problem", "Fact", "Air", "Art",
            "Area", "War", "History", "Party", "Result", "Change", "Morning", "Reason", "Research", "Girl", "Guy",
            "Moment", "Money", "Story", "Month", "Student", "Home", "Job", "Word", "Business", "Issue", "Side",
            "Kind", "Head", "Friend", "Power", "Game", "Line", "End", "Member", "Law", "Car", "City", "Community",
            "Name", "President", "Team", "Minute", "Idea", "Kid", "Body", "Information", "Back", "Parent", "Face",
            "Others", "Level", "Office", "Health", "Person", "History", "Art", "Way", "Map", "Family", "System",
            "Computer", "Meat", "Music", "Reading", "Method", "Data", "Food", "Understanding", "Theory", "Law",
            "Bird", "Literature", "Problem", "Software", "Control", "Knowledge", "Power", "Ability", "Economics",
            "Love", "Internet", "Television", "Science", "Library", "Nature", "Fact", "Product", "Idea", "Temperature",
            "Investment", "Area", "Society", "Activity", "Story", "Industry", "Media", "Thing", "Oven", "Community",
            "Definition", "Safety", "Quality", "Development", "Language", "Management", "Player", "Variety", "Video",
            "Week", "Security", "Country", "Exam", "Movie", "Organization", "Equipment", "Physics", "Analysis",
            "Policy", "Series", "Thought", "Basis", "Boyfriend", "Direction", "Strategy", "Technology", "Army",
            "Camera", "Freedom", "Paper", "Environment", "Child", "Instance", "Month", "Truth", "Marketing", "University",
            "Writing", "Article", "Department", "Difference", "Goal", "News", "Audience", "Fishing", "Growth", "Income",
            "Marriage", "User", "Combination", "Failure", "Meaning", "Medicine", "Philosophy", "Teacher", "Communication",
            "Night", "Chemistry", "Disease", "Disk", "Energy", "Nation", "Road", "Role", "Soup", "Advertising", "Location",
            "Success", "Addition", "Apartment", "Education", "Math", "Moment", "Painting", "Politics", "Attention",
            "Decision", "Event", "Property", "Shopping", "Student", "Wood", "Competition", "Distribution", "Entertainment",
            "Office", "Population", "President", "Unit", "Category", "Cigarette", "Context", "Introduction", "Opportunity",
            "Performance", "Driver", "Flight", "Length", "Magazine", "Newspaper", "Relationship", "Teaching", "Cell",
            "Dealer", "Finding", "Lake", "Member", "Message", "Phone", "Scene", "Appearance", "Association", "Concept",
            "Customer", "Death", "Discussion", "Housing", "Inflation", "Insurance", "Mood", "Woman", "Advice", "Blood",
            "Effort", "Expression", "Importance", "Opinion", "Payment", "Reality", "Responsibility", "Situation",
            "Skill", "Statement", "Wealth", "Application", "City", "County", "Depth", "Estate", "Foundation", "Grandmother",
            "Heart", "Perspective", "Photo", "Recipe", "Studio", "Topic", "Collection", "Depression", "Imagination",
            "Passion", "Percentage", "Resource", "Setting", "Ad", "Agency", "College", "Connection", "Criticism"
        ]

        private static let englishMediumWords = [
            "Bicycle", "Motorcycle", "Helicopter", "Submarine", "Telescope", "Microscope", "Camera", "Computer", "Keyboard", "Mouse",
            "Printer", "Guitar", "Piano", "Violin", "Drums", "Trumpet", "Saxophone", "Elephant", "Giraffe", "Kangaroo", "Penguin",
            "Dolphin", "Whale", "Octopus", "Butterfly", "Dragonfly", "Scorpion", "Chameleon", "Alligator", "Crocodile", "Volcano",
            "Earthquake", "Tornado", "Hurricane", "Galaxy", "Planet", "Comet", "Asteroid", "Universe", "Constellation", "Pyramid",
            "Castle", "Palace", "Temple", "Skyscraper", "Stadium", "Library", "Museum", "Hospital", "University", "Factory",
            "Restaurant", "Cinema", "Theater", "Circus", "Carnival", "Festival", "Vacation", "Holiday", "Birthday", "Wedding",
            "Anniversary", "Adventure", "Mystery", "Treasure", "Pirate", "Knight", "Wizard", "Dragon", "Unicorn", "Phoenix",
            "Scientist", "Artist", "Musician", "Actor", "Dancer", "Writer", "Doctor", "Teacher", "Engineer", "Chef",
            "Breakfast", "Lunch", "Dinner", "Dessert", "Popcorn", "Pizza", "Burger", "Sushi", "Salad", "Sandwich", "Rainbow",
            "Shadow", "Mirror", "Echo", "Dream", "Nightmare", "Surprise", "Secret", "Password", "Puzzle", "Riddle",
            "Champion", "Victory", "Defeat", "Success", "Failure", "Beginning", "Middle", "End", "Journey", "Destination",
            "Compass", "Map", "Medal", "Trophy", "Crown", "Throne", "Scepter", "Shield", "Sword", "Arrow", "Abundance",
            "Accountability", "Acquisition", "Adaptation", "Advancement", "Advocate", "Aesthetic", "Affection", "Agenda",
            "Ambiguity", "Ambition", "Analysis", "Anomaly", "Anticipation", "Application", "Appraisal", "Appreciation",
            "Arbitration", "Aspiration", "Assembly", "Assessment", "Asset", "Asylum", "Attitude", "Attraction", "Auction",
            "Audacity", "Augmentation", "Authenticity", "Authority", "Autonomy", "Availability", "Aversion", "Axiom",
            "Backbone", "Backdrop", "Backfire", "Backlash", "Backlog", "Backpack", "Backtrack", "Bailout", "Ballot",
            "Bankruptcy", "Bargain", "Barricade", "Barter", "Baseline", "Bastion", "Beacon", "Bedrock", "Benchmark",
            "Beneficiary", "Betrayal", "Beverage", "Bias", "Bibliography", "Bifurcation", "Bigotry", "Bystander",
            "Calamity", "Calculus", "Caliber", "Campaign", "Candidacy", "Canvas", "Capability", "Capital", "Captivity",
            "Cascade", "Catalyst", "Catastrophe", "Cavalry", "Ceasefire", "Celebration", "Censorship", "Centennial",
            "Ceremony", "Certainty", "Certification", "Charisma", "Chronicle", "Circuit", "Circulation", "Circumstance",
            "Citation", "Civilization", "Clarity", "Cleavage", "Cliche", "Clientele", "Climax", "Coalition", "Cohesion",
            "Coincidence", "Collaboration", "Collateral", "Colleague", "Collision", "Collusion", "Commemoration",
            "Commentary", "Commission", "Commitment", "Commodity", "Commotion", "Commute", "Compassion", "Compendium",
            "Compensation", "Competence", "Compilation", "Complacency", "Complement", "Complexity", "Compliance",
            "Complicity", "Component", "Composure", "Compound", "Compromise", "Concession", "Concoction", "Concord",
            "Concurrence", "Condition", "Condolence", "Conductor", "Confederacy", "Conference", "Confession",
            "Confidant", "Configuration", "Confinement", "Confirmation", "Confluence", "Conformity", "Confrontation",
            "Congestion", "Conglomerate", "Congregation", "Congruence", "Conjecture", "Conjunction", "Connection",
            "Connoisseur", "Connotation", "Conscience", "Consciousness", "Conscription", "Consensus", "Consequence",
            "Conservation", "Conservatory", "Consideration", "Consignment", "Consistency", "Consortium", "Conspiracy",
            "Consternation", "Constituency", "Constraint", "Construction", "Consultant", "Consumption", "Contagion",
            "Contemplation", "Contender", "Contention", "Contingency", "Continuation", "Contour", "Contraband",
            "Contraction", "Contradiction", "Contraption", "Contrast", "Contribution", "Contrition", "Controversy",
            "Conundrum", "Convention", "Convergence", "Conversation", "Conversion", "Conviction", "Conviviality",
            "Convoy", "Cooperation", "Coordination", "Corollary", "Coronation", "Corporation", "Corpus", "Correlation",
            "Correspondence", "Corridor", "Corroboration", "Corruption", "Cosmos", "Coterie", "Countdown", "Counterpart",
            "Courage", "Courier", "Covenant", "Coverage", "Credibility", "Credo", "Creed", "Crescendo", "Crest",
            "Crisis", "Criterion", "Critique", "Crux", "Culmination", "Culpability", "Cult", "Cultivation", "Cure",
            "Curfew", "Currency", "Current", "Curriculum", "Cursory", "Custody", "Cylinder", "Cynicism", "Dabble",
            "Dagger", "Damsel", "Daredevil", "Dawn", "Daze", "Dazzle", "Deadline", "Deadlock", "Dealership", "Dearth",
            "Debacle", "Debris", "Debut", "Decadence", "Decathlon", "Deceit", "Decency", "Deception", "Decibel", "Decision",
            "Declaration", "Decline", "Decorum", "Decree", "Dedication", "Deduction", "Default", "Defeat", "Defect",
            "Defendant", "Defender", "Defiance", "Deficiency", "Deficit", "Deflection", "Deformity", "Degradation",
            "Deity", "Delegate", "Delegation", "Delicacy", "Delight", "Delinquent", "Delirium", "Delivery", "Deluge",
            "Delusion", "Demagogue", "Demand", "Demise", "Democracy", "Demographic", "Demolition", "Demon", "Demonstration",
            "Denial", "Denizen", "Denomination", "Density", "Departure", "Dependence", "Depiction", "Depletion", "Deportation",
            "Deposition", "Depravity", "Deprecation", "Deprivation", "Deputy", "Derelict", "Derision", "Derivation",
            "Dermatologist", "Derrick", "Descent", "Description", "Desecration", "Desertion", "Designation", "Desire",
            "Desolation", "Despair", "Desperado", "Despot", "Destiny", "Destitution", "Destruction", "Detachment",
            "Detainee", "Detection", "Detention", "Detergent", "Deterioration", "Determination", "Deterrent", "Detestation",
            "Detonation", "Detour", "Detriment", "Devaluation", "Devastation", "Development", "Deviation", "Device", "Devotion"
        ]

        private static let englishHardWords = [
            "Architecture", "Philosophy", "Psychology", "Sociology", "Anthropology", "Archaeology", "Astronomy", "Biology", "Chemistry", "Physics",
            "Geology", "Ecology", "Genetics", "Metaphysics", "Epistemology", "Ontology", "Democracy", "Republic", "Monarchy", "Anarchy",
            "Capitalism", "Socialism", "Communism", "Fascism", "Bureaucracy", "Diplomacy", "Legislation", "Jurisprudence", "Sovereignty", "Constitution",
            "Photosynthesis", "Metamorphosis", "Symbiosis", "Evolution", "Gravity", "Relativity", "Quantum", "Paradox", "Enigma", "Dilemma",
            "Nostalgia", "Empathy", "Apathy", "Euphoria", "Melancholy", "Serendipity", "Synchronicity", "Juxtaposition", "Cacophony", "Eloquence",
            "Ambiguity", "Subtlety", "Irony", "Satire", "Metaphor", "Allegory", "Symbolism", "Abstract", "Surrealism", "Impressionism",
            "Renaissance", "Baroque", "Gothic", "Neoclassicism", "Modernism", "Postmodernism", "Consciousness", "Subconscious", "Intuition", "Imagination",
            "Procrastination", "Ambition", "Perseverance", "Resilience", "Integrity", "Humility", "Generosity", "Compassion", "Wisdom", "Courage",
            "Alchemy", "Astrology", "Mythology", "Folklore", "Legend", "Prophecy", "Miracle", "Destiny", "Karma", "Nirvana",
            "Cryptocurrency", "Blockchain", "Algorithm", "Heuristic", "Cybernetics", "Biotechnology", "Nanotechnology", "Geopolitics", "Macroeconomics", "Microeconomics",
            "Equilibrium", "Catalyst", "Hypothesis", "Theorem", "Axiom", "Corollary", "Paradigm", "Phenomenon", "Spectrum", "Continuum", "Infinity",
            "Abnegation", "Abscond", "Abstruse", "Accede", "Accost", "Accretion", "Acumen", "Adamant", "Admonish", "Adumbrate",
            "Adversary", "Aegis", "Affront", "Aggrandize", "Alacrity", "Alias", "Alleviate", "Allusion", "Altruism", "Amalgamate",
            "Ameliorate", "Amortize", "Anachronism", "Anathema", "Ancillary", "Animosity", "Antediluvian", "Antithesis",
            "Aphorism", "Apocryphal", "Apostasy", "Apotheosis", "Approbation", "Arcane", "Archetype", "Arduous", "Arrogate",
            "Ascetic", "Asperity", "Assiduous", "Assuage", "Astringent", "Atavism", "Auspicious", "Austere", "Autocratic",
            "Avant-garde", "Avarice", "Avow", "Baleful", "Banal", "Beatify", "Bedlam", "Beguile", "Behemoth", "Beleaguer",
            "Belie", "Bellicose", "Belligerent", "Benediction", "Benevolent", "Benign", "Bequeath", "Berate", "Bereft",
            "Bilious", "Bilk", "Blandishment", "Blasphemy", "Blatant", "Boondoggle", "Boorish", "Bourgeois", "Bovine",
            "Brackish", "Brandish", "Bravado", "Brevity", "Brigand", "Brobdingnagian", "Brusque", "Bucolic", "Bumptious",
            "Burgeon", "Burnish", "Buttress", "Cabal", "Cache", "Cajole", "Calumny", "Candid", "Cant", "Cantankerous",
            "Capacious", "Capitulate", "Capricious", "Captious", "Carrion", "Castigate", "Catharsis", "Caustic", "Cavalier",
            "Cavil", "Celerity", "Censure", "Cerebral", "Chagrin", "Charlatan", "Chary", "Chasten", "Chicanery", "Chimerical",
            "Choleric", "Chortle", "Churlish", "Circuitous", "Circumlocution", "Circumscribe", "Circumspect", "Circumvent",
            "Clairvoyant", "Clandestine", "Clemency", "Coalesce", "Coda", "Coerce", "Cogent", "Cogitate", "Cognizant",
            "Coherent", "Cohort", "Colloquial", "Collusion", "Comeliness", "Commensurate", "Commiserate", "Complaisant",
            "Concomitant", "Concordat", "Condign", "Condone", "Conflagration", "Congeal", "Congenial", "Congenital",
            "Congruous", "Conjecture", "Connive", "Consecrate", "Consonant", "Consternation", "Contiguous", "Continence",
            "Contravene", "Contrite", "Contumacious", "Convivial", "Copious", "Corroborate", "Coruscate", "Cosset",
            "Countenance", "Countermand", "Covenant", "Covert", "Craven", "Credence", "Credulous", "Crepuscular",
            "Crescendo", "Culpable", "Cupidity", "Curmudgeon", "Cursory", "Cynosure", "Dastardly", "Daunt", "Dearth",
            "Debauch", "Debilitate", "Decimate", "Decorous", "Decry", "Defalcate", "Defenestrate", "Deign", "Deleterious",
            "Delineate", "Demur", "Denigrate", "Denouement", "Deprecate", "Depredate", "Deride", "Descry", "Desiccate",
            "Desuetude", "Desultory", "Deter", "Diaphanous", "Diatribe", "Dichotomy", "Didactic", "Diffident", "Digress",
            "Dilatory", "Dilettante", "Din", "Dint", "Dirge", "Disabuse", "Disaffect", "Disavow", "Discomfit", "Disconcert",
            "Disconsolate", "Discordant", "Discursive", "Disdain", "Disingenuous", "Disinterested", "Disparage",
            "Disparate", "Dissemble", "Disseminate", "Dissident", "Dissolute", "Dissonant", "Distaff", "Distend",
            "Dither", "Diurnal", "Diverge", "Divest", "Divulge", "Doctrinaire", "Dogmatic", "Doleful", "Dolorous",
            "Dolt", "Dormant", "Dour", "Draconian", "Droll", "Dross", "Dubious", "Duplicity", "Duress", "Ebullient",
            "Eclectic", "Eclat", "Edacious", "Edict", "Edify", "Efface", "Efferent", "Effete", "Efficacious", "Effrontery",
            "Effulgent", "Egregious", "Egress", "Elan", "Elicit", "Elide", "Eloquent", "Elucidate", "Emaciate", "Emanate",
            "Emancipate", "Embargo", "Embellish", "Embezzle", "Embroil", "Emend", "Eminent", "Emollient", "Emolument",
            "Emulate", "Enervate", "Enfranchise", "Engender", "Enjoin", "Enmity", "Ennui", "Enormity", "Ensorcell", "Entail",
            "Enthrall", "Entrench", "Ephemeral", "Epicure", "Epigram", "Epilogue", "Epistle", "Epithet", "Epitome",
            "Equanimity", "Equivocate", "Errant", "Erudite", "Eschew", "Esoteric", "Espouse", "Estrange", "Ethereal",
            "Etiolate", "Eulogy", "Euphemism", "Evanescent", "Evince", "Exacerbate", "Exculpate", "Execrate", "Exegesis",
            "Exhort", "Exhume", "Exigency", "Exiguous", "Exonerate", "Exorbitant", "Expiate", "Expunge", "Expurgate",
            "Extant", "Extemporaneous", "Extirpate", "Extol", "Extraneous", "Extrapolate", "Extricate", "Exult"
        ]
    
        // MARK: - 🇺🇦 Ukrainian Word Lists
        private static let ukrainianEasyWords = [
            // Original
            "Сонце", "Місяць", "Зірка", "Хмара", "Дощ", "Сніг", "Вітер", "Дерево", "Квітка", "Трава", "Річка", "Океан",
            "Гора", "Дім", "Двері", "Вікно", "Стілець", "Стіл", "Ліжко", "Книга", "Ручка", "Папір", "Телефон", "Ключ",
            "Авто", "Дорога", "Міст", "Човен", "Поїзд", "Літак", "Кіт", "Пес", "Птах", "Риба", "Лев", "Тигр", "Ведмідь",
            "Яблуко", "Банан", "Апельсин", "Хліб", "Сир", "Вода", "Молоко", "Кава", "Чай", "Сік", "Рука", "Нога",
            "Око", "Ніс", "Рот", "Вухо", "Волосся", "Сміх", "Плач", "Біг", "Ходьба", "Стрибок", "Плавання", "Спів",
            "Танець", "Читання", "Писання", "Сон", "Їжа", "Напій", "Гра", "Робота", "Щастя", "Сум", "Великий", "Малий",
            "Гарячий", "Холодний", "Червоний", "Синій", "Зелений", "Жовтий", "М'яч", "Коробка", "Годинник", "Лампа", "Взуття", "Шапка",
            // Added
            "Земля", "Небо", "Вогонь", "Повітря", "Камінь", "Пісок", "Ліс", "Поле", "Сад", "Город", "Озеро", "Море",
            "Струмок", "Берег", "Острів", "Крига", "Пар", "Туман", "Роса", "Град", "Грім", "Блискавка", "Веселка", "Полум'я",
            "Іскра", "Стіна", "Стеля", "Підлога", "Дах", "Кухня", "Кімната", "Ванна", "Балкон", "Сходи", "Льох", "Горище",
            "Меблі", "Шафа", "Диван", "Крісло", "Полиця", "Комод", "Дзеркало", "Килим", "Штора", "Картина", "Ваза", "Фото",
            "Ложка", "Виделка", "Ніж", "Тарілка", "Чашка", "Склянка", "Каструля", "Чайник", "Плита", "Духовка", "Мийка", "Кран",
            "Мило", "Рушник", "Губка", "Щітка", "Гребінець", "Ножиці", "Нитки", "Голка", "Ґудзик", "Тканина", "Одяг", "Сукня",
            "Спідниця", "Штани", "Джинси", "Сорочка", "Футболка", "Светр", "Куртка", "Пальто", "Шарф", "Рукавиці", "Шкарпетки", "Пояс",
            "Капелюх", "Кепка", "Окуляри", "Сумка", "Гаманець", "Парасолька", "Ранок", "День", "Вечір", "Ніч", "Світанок", "Захід",
            "Сніданок", "Обід", "Вечеря", "Зима", "Весна", "Літо", "Осінь", "Тиждень", "Рік", "Свято", "Подарунок", "Гість",
            "Сім'я", "Мама", "Тато", "Брат", "Сестра", "Син", "Донька", "Бабуся", "Дідусь", "Друг", "Ворог", "Сусід",
            "Людина", "Дитина", "Голова", "Шия", "Плече", "Спина", "Живіт", "Палець", "Долоня", "Лікоть", "Коліно", "Стопа",
            "Обличчя", "Лоб", "Брова", "Щока", "Підборіддя", "Губи", "Зуби", "Язик", "Горло", "Кров", "Кістка", "Шкіра",
            "Серце", "Мозок", "Корова", "Кінь", "Вівця", "Коза", "Свиня", "Курка", "Качка", "Гуска", "Кролик", "Миша",
            "Білка", "Заєць", "Вовк", "Лисиця", "Їжак", "Олень", "Сова", "Голуб", "Ворона", "Горобець", "Ластівка", "Лелека",
            "Орел", "Чайка", "Жаба", "Змія", "Ящірка", "Мураха", "Комар", "Муха", "Бджола", "Метелик", "Павук", "Черв'як",
            "Овочі", "Фрукти", "Ягода", "Картопля", "Морква", "Цибуля", "Часник", "Буряк", "Капуста", "Огірок", "Помідор", "Перець",
            "Груша", "Слива", "Вишня", "Черешня", "Полуниця", "Малина", "Смородина", "Виноград", "Кавун", "Диня", "Лимон", "Горіх",
            "Гриб", "М'ясо", "Сало", "Ковбаса", "Яйце", "Масло", "Олія", "Сметана", "Цукор", "Сіль", "Борошно", "Крупа",
            "Каша", "Суп", "Борщ", "Вареник", "Пиріг", "Торт", "Печиво", "Цукерка", "Шоколад", "Мед", "Варення", "Морозиво",
            "Школа", "Клас", "Урок", "Крейда", "Дошка", "Парта", "Зошит", "Олівець", "Гумка", "Лінійка", "Пенал", "Рюкзак",
            "Вчитель", "Учень", "Оцінка", "Дзвінок", "Зміна", "Книгарня", "Магазин", "Ринок", "Аптека", "Пошта", "Банк", "Парк",
            "Лікарня", "Цирк", "Театр", "Музей", "Кіно", "Стадіон", "Басейн", "Пляж", "Вокзал", "Аеропорт", "Вулиця", "Площа",
            "Зупинка", "Світлофор", "Машина", "Автобус", "Тролейбус", "Трамвай", "Метро", "Таксі", "Велосипед", "Черевик", "Сапог",
            "Іграшка", "Лялька", "Робот", "Кубик", "Пазл", "Гойдалка", "Гірка", "Пісочниця", "Відро", "Лопата", "Повітря", "Номер",
            "Колір", "Звук", "Запах", "Смак", "Слово", "Буква", "Цифра", "Пісня", "Музика", "Казка", "Вірш", "Загадка",
            "Ім'я", "Прізвище", "Радість", "Смуток", "Злість", "Страх", "Подив", "Любов", "Дружба", "Сон", "Мрія", "Посмішка"
        ]
        
        private static let ukrainianMediumWords = [
            // Original
            "Велосипед", "Мотоцикл", "Вертоліт", "Субмарина", "Телескоп", "Мікроскоп", "Камера", "Комп'ютер", "Клавіатура", "Миша",
            "Принтер", "Гітара", "Піаніно", "Скрипка", "Барабани", "Труба", "Саксофон", "Слон", "Жираф", "Кенгуру", "Пінгвін",
            "Дельфін", "Кит", "Восьминіг", "Метелик", "Бабка", "Скорпіон", "Хамелеон", "Алігатор", "Крокодил", "Вулкан",
            "Землетрус", "Торнадо", "Ураган", "Галактика", "Планета", "Комета", "Астероїд", "Всесвіт", "Сузір'я", "Піраміда",
            "Замок", "Палац", "Храм", "Хмарочос", "Стадіон", "Бібліотека", "Музей", "Лікарня", "Університет", "Фабрика",
            "Ресторан", "Кінотеатр", "Театр", "Цирк", "Карнавал", "Фестиваль", "Відпустка", "Свято", "День народження", "Весілля",
            "Річниця", "Пригода", "Таємниця", "Скарб", "Пірат", "Лицар", "Чарівник", "Дракон", "Єдиноріг", "Фенікс",
            "Науковець", "Художник", "Музикант", "Актор", "Танцюрист", "Письменник", "Лікар", "Вчитель", "Інженер", "Кухар",
            "Сніданок", "Обід", "Вечеря", "Десерт", "Попкорн", "Піца", "Бургер", "Суші", "Салат", "Сендвіч", "Веселка",
            "Тінь", "Дзеркало", "Луна", "Сон", "Кошмар", "Сюрприз", "Секрет", "Пароль", "Пазл", "Загадка",
            "Чемпіон", "Перемога", "Поразка", "Успіх", "Невдача", "Початок", "Середина", "Кінець", "Подорож", "Призначення",
            "Компас", "Карта", "Медаль", "Трофей", "Корона", "Трон", "Скіпетр", "Щит", "Меч", "Стріла",
            // Added
            "Акваланг", "Дирижабль", "Катамаран", "Танкер", "Криголам", "Екскаватор", "Бульдозер", "Трактор", "Комбайн", "Супутник",
            "Ракета", "Капсула", "Орбіта", "Атмосфера", "Стратосфера", "Гідросфера", "Біосфера", "Літосфера", "Екватор", "Меридіан",
            "Континент", "Материк", "Архіпелаг", "Півострів", "Протока", "Затока", "Лагуна", "Айсберг", "Льодовик", "Пустеля",
            "Савана", "Джунглі", "Тайга", "Тундра", "Прерія", "Оазис", "Каньйон", "Водоспад", "Гейзер", "Печера",
            "Лабіринт", "Фортеця", "Цитадель", "Акведук", "Колізей", "Пантеон", "Мавзолей", "Некрополь", "Обсерваторія", "Планетарій",
            "Амфітеатр", "Консерваторія", "Філармонія", "Галерея", "Вернісаж", "Експозиція", "Інсталяція", "Перформанс", "Флешмоб", "Концерт",
            "Опера", "Балет", "Мюзикл", "Оперета", "Симфонія", "Увертюра", "Арія", "Соло", "Дует", "Хор",
            "Жанр", "Роман", "Повість", "Новела", "Детектив", "Фантастика", "Комедія", "Трагедія", "Драма", "Епос",
            "Герой", "Персонаж", "Антагоніст", "Протагоніст", "Сюжет", "Кульмінація", "Розв'язка", "Інтрига", "Конфлікт", "Діалог",
            "Монолог", "Цитата", "Афоризм", "Епіграф", "Псевдонім", "Автор", "Редактор", "Видавець", "Ілюстратор", "Тираж",
            "Професія", "Адвокат", "Архітектор", "Астроном", "Бухгалтер", "Ветеринар", "Геолог", "Дизайнер", "Журналіст", "Історик",
            "Космонавт", "Льотчик", "Менеджер", "Нотаріус", "Окуліст", "Перукар", "Програміст", "Психолог", "Режисер", "Стоматолог",
            "Терапевт", "Фармацевт", "Фермер", "Фотограф", "Хімік", "Хірург", "Юрист", "Археолог", "Дипломат", "Перекладач",
            "Мавпа", "Горила", "Шимпанзе", "Орангутан", "Лемур", "Коала", "Панда", "Носоріг", "Бегемот", "Зебра",
            "Антилопа", "Гепард", "Леопард", "Пума", "Рись", "Шакал", "Гієна", "Скунс", "Єнот", "Бобер",
            "Видра", "Морж", "Тюлень", "Акула", "Скат", "Кальмар", "Краб", "Креветка", "Омар", "Медуза",
            "Папуга", "Канарейка", "Фламінго", "Павич", "Страус", "Тукан", "Колібрі", "Кондор", "Гриф", "Яструб",
            "Кобра", "Гадюка", "Пітон", "Анаконда", "Ігуана", "Варан", "Геккон", "Тритон", "Саламандра", "Тарантул",
            "Терміт", "Сарана", "Сонечко", "Світлячок", "Богомол", "Цикада", "Джміль", "Оса", "Шершень", "Ґедзь",
            "Наука", "Фізика", "Хімія", "Біологія", "Географія", "Астрономія", "Екологія", "Генетика", "Ботаніка", "Зоологія",
            "Анатомія", "Психологія", "Соціологія", "Філософія", "Історія", "Археологія", "Економіка", "Політологія", "Логіка", "Математика",
            "Алгебра", "Геометрія", "Тригонометрія", "Формула", "Рівняння", "Теорема", "Аксіома", "Гіпотеза", "Теорія", "Експеримент",
            "Атом", "Молекула", "Клітина", "Ядро", "Протон", "Нейтрон", "Електрон", "Іон", "Ізотоп", "Елемент",
            "Реакція", "Сполука", "Розчин", "Кислота", "Луг", "Оксид", "Метал", "Сплав", "Кристал", "Мінерал",
            "Енергія", "Сила", "Швидкість", "Маса", "Тиск", "Температура", "Напруга", "Частота", "Амплітуда", "Резонанс",
            "Спорт", "Футбол", "Баскетбол", "Волейбол", "Теніс", "Бокс", "боротьба", "Плавання", "Гімнастика", "Атлетика",
            "Марафон", "Тріатлон", "Регбі", "Гольф", "Хокей", "Фігурнекатання", "Біатлон", "Сноуборд", "Серфінг", "Дайвінг",
            "Турнір", "Змагання", "Олімпіада", "Рекорд", "Тренер", "Спортсмен", "Команда", "Вболівальник", "Арбітр", "Допінг",
            "Характер", "Темперамент", "Інтелект", "Талант", "Здібність", "Навичка", "Звичка", "Інстинкт", "Рефлекс", "Емоція",
            "Почуття", "Настрій", "Бажання", "Мрія", "Мета", "Ціль", "Амбіція", "Мотивація", "Натхнення", "Інтуїція",
            "Свідомість", "Пам'ять", "Уява", "Мислення", "Сприйняття", "Відчуття", "Асоціація", "Ілюзія", "Галюцинація", "Гіпноз",
            "Держава", "Країна", "Республіка", "Монархія", "Імперія", "Федерація", "Конфедерація", "Столиця", "Кордон", "Територія",
            "Населення", "Громадянин", "Патріот", "Президент", "Парламент", "Уряд", "Міністр", "Депутат", "Мер", "Конституція",
            "Закон", "Право", "Обов'язок", "Свобода", "Демократія", "Вибори", "Голосування", "Опозиція", "Мітинг", "Революція",
            "Армія", "Флот", "Солдат", "Офіцер", "Генерал", "Зброя", "Танк", "Винищувач", "Авіаносець", "Радар",
            "Мистецтво", "Живопис", "Скульптура", "Архітектура", "Графіка", "Дизайн", "Музика", "Література", "Поезія", "Проза",
            "Пейзаж", "Портрет", "Натюрморт", "Абстракція", "Композиція", "Палітра", "Відтінок", "Світлотінь", "Перспектива", "Стиль",
            "Інструмент", "Обладнання", "Механізм", "Пристрій", "Агрегат", "Двигун", "Генератор", "Трансформатор", "Компресор", "Турбіна",
            "Символ", "Знак", "Емблема", "Логотип", "Герб", "Прапор", "Гімн", "Девіз", "Традиція", "Ритуал"
        ]
        
        private static let ukrainianHardWords = [
            // Original
            "Архітектура", "Філософія", "Психологія", "Соціологія", "Антропологія", "Археологія", "Астрономія", "Біологія", "Хімія", "Фізика",
            "Геологія", "Екологія", "Генетика", "Метафізика", "Епістемологія", "Онтологія", "Демократія", "Республіка", "Монархія", "Анархія",
            "Капіталізм", "Соціалізм", "Комунізм", "Фашизм", "Бюрократія", "Дипломатія", "Законодавство", "Юриспруденція", "Суверенітет", "Конституція",
            "Фотосинтез", "Метаморфоза", "Симбіоз", "Еволюція", "Гравітація", "Відносність", "Квант", "Парадокс", "Енігма", "Дилема",
            "Ностальгія", "Емпатія", "Апатія", "Ейфорія", "Меланхолія", "Серендипність", "Синхронність", "Зіставлення", "Какофонія", "Красномовство",
            "Двозначність", "Витонченість", "Іронія", "Сатира", "Метафора", "Алегорія", "Символізм", "Абстракція", "Сюрреалізм", "Імпресіонізм",
            "Ренесанс", "Бароко", "Готика", "Неокласицизм", "Модернізм", "Постмодернізм", "Свідомість", "Підсвідомість", "Інтуїція", "Уява",
            "Прокрастинація", "Амбіція", "Наполегливість", "Стійкість", "Цілісність", "Смирення", "Щедрість", "Співчуття", "Мудрість", "Хоробрість",
            "Алхімія", "Астрологія", "Міфологія", "Фольклор", "Легенда", "Пророцтво", "Диво", "Доля", "Карма", "Нірвана",
            "Криптовалюта", "Блокчейн", "Алгоритм", "Евристика", "Кібернетика", "Біотехнологія", "Нанотехнологія", "Геополітика", "Макроекономіка", "Мікроекономіка",
            "Рівновага", "Каталізатор", "Гіпотеза", "Теорема", "Аксіома", "Наслідок", "Парадигма", "Феномен", "Спектр", "Континуум", "Нескінченність",
            // Added
            "Абсолютизм", "Автократія", "Адаптація", "Аскетизм", "Асиміляція", "Атрибут", "Аутентичність", "Гегемонія", "Гедонізм", "Герменевтика",
            "Гіпербола", "Гносеологія", "Гомеостаз", "Деконструкція", "Детермінізм", "Діалектика", "Дивергенція", "Дискретність", "Дисонанс", "Догматизм",
            "Дуалізм", "Екзистенціалізм", "Еклектика", "Експансія", "Екстраполяція", "Емпіризм", "Ентропія", "Есхатологія", "Етимологія", "Ідентичність",
            "Ідеологія", "Ієрархія", "Іманентність", "Імператив", "Індукція", "Інтеграція", "Інтерпретація", "Інтроспекція", "Катарсис", "Квінтесенція",
            "Когерентність", "Колаборація", "Конвергенція", "Конгломерат", "Консенсус", "Концепція", "Кореляція", "Легітимність", "Лібералізм", "Маніфестація",
            "Матеріалізм", "Метафора", "Методологія", "Мізантропія", "Мімікрія", "Моногамія", "Нарцисизм", "Нігілізм", "Номенклатура", "Олігархія",
            "Опозиція", "Панацея", "Пантеїзм", "Пацифізм", "Перфекціонізм", "Плебісцит", "Плюралізм", "Полігамія", "Популізм", "Прагматизм",
            "Прерогатива", "Прецедент", "Протекціонізм", "Раціоналізм", "Регресія", "Резонанс", "Реквієм", "Релятивізм", "Рефлексія", "Реформація",
            "Риторика", "Сегрегація", "Семіотика", "Синергія", "Синтез", "Систематика", "Скептицизм", "Соліпсизм", "Спекуляція", "Стагнація",
            "Стереотип", "Стоїцизм", "Субвенція", "Сублімація", "Теологія", "Теократія", "Толерантність", "Тоталітаризм", "Трансгуманізм", "Трансцендентність",
            "Уніфікація", "Утилітаризм", "Утопія", "Фантасмагорія", "Фаталізм", "Феноменологія", "Філантропія", "Фрустрація", "Фундаменталізм", "Харизма",
            "Холізм", "Централізація", "Шовінізм", "Абстракціонізм", "Авангардизм", "Агностицизм", "Антагонізм", "Апологія", "Архетип", "Верифікація",
            "Віртуальність", "Волюнтаризм", "Генезис", "Гравюра", "Декаданс", "Демагогія", "Денонсація", "Деспотизм", "Диверсифікація", "Дискримінація",
            "Диференціація", "Доктрина", "Експресіонізм", "Екстремізм", "Елітаризм", "Епітет", "Ерудиція", "Естетика", "Етикет", "Імпровізація",
            "Інновація", "Інсинуація", "Інцидент", "Кваліфікація", "Класицизм", "Клерикалізм", "Кодифікація", "Колізія", "Компенсація", "Компіляція",
            "Компроміс", "Конвенція", "Консолідація", "Конформізм", "Концентрація", "Корупція", "Космополітизм", "Критерій", "Латентність", "Лейтмотив",
            "Лінгвістика", "Лояльність", "Маргінальність", "Меркантилізм", "Метрополія", "Мілітаризм", "Модернізація", "Монополія", "Мораторій", "Обструкція",
            "Оксюморон", "Оптимізація", "Палітра", "Пандемія", "Паритет", "Патриціат", "Пафос", "Педантичність", "Пертурбація", "Полеміка",
            "Полісемія", "Преамбула", "Превентивний", "Презентація", "Презумпція", "Пріоритет", "Провокація", "Прогноз", "Пролонгація", "Пропаганда",
            "Протекторат", "Прототип", "Радикалізм", "Ратифікація", "Реабілітація", "Реваншизм", "Ревізіонізм", "Регламент", "Резервація", "Резистентність",
            "Реквізиція", "Рентабельність", "Репатріація", "Репресія", "Репродукція", "Репутація", "Реставрація", "Реструктуризація", "Ретроспектива", "Референдум",
            "Рецензія", "Рудимент", "Самоідентифікація", "Сакралізація", "Санкція", "Сарказм", "Свобода", "Секвестр", "Секуляризація", "Сепаратизм",
            "Симуляція", "Схоластика", "Таксономія", "Тенденція", "Типологія", "Транзит", "Транскрипція", "Трансформація", "Тріумф", "Узурпація",
            "Ультиматум", "Універсалізм", "Фальсифікація", "Фанатизм", "Фемінізм", "Фікція", "Флегматичність", "Фрагментація", "Фракція", "Франшиза",
            "Футурологія", "Цензура", "Циркуляція", "Цивілізація", "Чародійство", "Чревовіщатель", "Юрисдикція", "Ятрогенія", "Абсорбція", "Анігіляція",
            "Апогей", "Асимптота", "Біоніка", "Валентність", "Вектор", "Вібрація", "Гідродинаміка", "Гіперзвук", "Дедукція", "Дефляція",
            "Дифракція", "Дисперсія", "Дифузія", "Еквівалент", "Ексцес", "Електроліз", "Емісія", "Ізоморфізм", "Ізотоп", "Імпульс",
            "Інверсія", "Інерція", "Інтерференція", "Катаболізм", "Кінетика", "Коефіцієнт", "Конвекція", "Люмінесценція", "Магнетизм", "Матриця",
            "Модуляція", "Нейтрино", "Осмос", "Парабола", "Перигей", "Поляризація", "Проекція", "Пульсар", "Радіація", "Регенерація",
            "Редукція", "Рефракція", "Сингулярність", "Скаляр", "Сублімація", "Тангенс", "Термодинаміка", "Траєкторія", "Турбулентність", "Фотоефект"
        ]
    
    // MARK: - 🇷🇺 Russian Word Lists
        private static let russianEasyWords = [
            // Original
            "Солнце", "Луна", "Звезда", "Облако", "Дождь", "Снег", "Ветер", "Дерево", "Цветок", "Трава", "Река", "Океан",
            "Гора", "Дом", "Дверь", "Окно", "Стул", "Стол", "Кровать", "Книга", "Ручка", "Бумага", "Телефон", "Ключ",
            "Машина", "Дорога", "Мост", "Лодка", "Поезд", "Самолет", "Кот", "Собака", "Птица", "Рыба", "Лев", "Тигр",
            "Медведь", "Яблоко", "Банан", "Апельсин", "Хлеб", "Сыр", "Вода", "Молоко", "Кофе", "Чай", "Сок", "Рука",
            "Нога", "Глаз", "Нос", "Рот", "Ухо", "Волосы", "Смех", "Плач", "Бег", "Ходьба", "Прыжок", "Плавание",
            "Пение", "Танец", "Чтение", "Письмо", "Сон", "Еда", "Напиток", "Игра", "Работа", "Счастье", "Грусть", "Большой",
            "Маленький", "Горячий", "Холодный", "Красный", "Синий", "Зеленый", "Желтый", "Мяч", "Коробка", "Часы", "Лампа", "Обувь",
            // Added
            "Лес", "Поле", "Озеро", "Море", "Остров", "Пустыня", "Песок", "Камень", "Земля", "Небо",
            "Огонь", "Воздух", "Утро", "День", "Вечер", "Ночь", "Свет", "Тьма", "Звук", "Тишина",
            "Кухня", "Комната", "Ванна", "Стена", "Пол", "Потолок", "Лестница", "Крыша", "Сад", "Забор",
            "Шкаф", "Полка", "Зеркало", "Картина", "Ковер", "Диван", "Подушка", "Одеяло", "Вилка", "Ложка",
            "Нож", "Тарелка", "Чашка", "Стакан", "Бутылка", "Единорог", "Карандаш", "Тетрадь", "Рюкзак", "Школа",
            "Учитель", "Ученик", "Врач", "Больница", "Аптека", "Лекарство", "Полиция", "Пожарный", "Магазин", "Деньги",
            "Кошелек", "Сумка", "Одежда", "Рубашка", "Штаны", "Платье", "Юбка", "Шапка", "Шарф", "Куртка",
            "Пальто", "Носки", "Перчатки", "Волк", "Лиса", "Заяц", "Белка", "Ежик", "Лошадь", "Корова",
            "Свинья", "Овца", "Курица", "Утка", "Гусь", "Мышь", "Лягушка", "Змея", "Муха", "Комар",
            "Пчела", "Паук", "Завтрак", "Обед", "Ужин", "Суп", "Каша", "Мясо", "Картошка", "Морковь",
            "Лук", "Капуста", "Огурец", "Помидор", "Груша", "Слива", "Виноград", "Арбуз", "Сахар", "Соль",
            "Масло", "Конфета", "Торт", "Печенье", "Мороженое", "Голова", "Шея", "Плечо", "Спина", "Живот",
            "Палец", "Ладонь", "Колено", "Стопа", "Зуб", "Язык", "Губы", "Бровь", "Щека", "Лоб",
            "Семья", "Мама", "Папа", "Брат", "Сестра", "Бабушка", "Дедушка", "Друг", "Сосед", "Гость",
            "Радость", "Страх", "Злость", "Улыбка", "Слеза", "Голос", "Слово", "Вопрос", "Ответ", "История",
            "Сказка", "Музыка", "Песня", "Фильм", "Мультик", "Цвет", "Форма", "Размер", "Запах", "Вкус",
            "Белый", "Черный", "Серый", "Коричневый", "Оранжевый", "Фиолетовый", "Розовый", "Золото", "Серебро", "Железо",
            "Стекло", "Дерево", "Планета", "Буря", "Гром", "Молния", "Радуга", "Туман", "Лед", "Пар",
            "Номер", "Буква", "Зима", "Весна", "Лето", "Осень", "Год", "Месяц", "Неделя", "Час",
            "Минута", "Секунда", "Город", "Деревня", "Улица", "Площадь", "Парк", "Ферма", "Вокзал", "Аэропорт",
            "Порт", "Пляж", "Берег", "Волна", "Корабль", "Парус", "Якорь", "Весло", "Колесо", "Мотор",
            "Бензин", "Скорость", "Высота", "Глубина", "Ширина", "Длина", "Сила", "Слабость", "Здоровье", "Болезнь",
            "Спорт", "Футбол", "Баскетбол", "Хоккей", "Теннис", "Шахматы", "Карта", "Флаг", "Корона", "Замок",
            "Башня", "Пещера", "Костер", "Дым", "Зола", "Уголь", "Искра", "Пламя", "Тепло", "Холод",
            "Начало", "Конец", "Середина", "Верх", "Низ", "Право", "Лево", "Центр", "Край", "Угол",
            "Линия", "Точка", "Круг", "Квадрат", "Треугольник", "Шар", "Куб", "Пирамида", "Цифра", "Инструмент",
            "Молоток", "Гвоздь", "Пила", "Топор", "Лопата", "Грабли", "Кисть", "Краска", "Клей", "Нитки",
            "Иголка", "Ткань", "Узор", "Праздник", "Подарок", "Годовщина", "Свадьба", "Гость", "Шум", "Крик",
            "Шепот", "Мысль", "Мечта", "Желание", "Надежда", "Вера", "Любовь", "Ненависть", "Дружба", "Ссора",
            "Помощь", "Забота", "Удача", "Ошибка", "Победа", "Поражение", "Битва", "Война", "Мир", "Оружие"
        ]
        
        private static let russianMediumWords = [
            // Original
            "Велосипед", "Мотоцикл", "Вертолет", "Субмарина", "Телескоп", "Микроскоп", "Камера", "Компьютер", "Клавиатура", "Мышь",
            "Принтер", "Гитара", "Пианино", "Скрипка", "Барабаны", "Труба", "Саксофон", "Слон", "Жираф", "Кенгуру", "Пингвин",
            "Дельфин", "Кит", "Осьминог", "Бабочка", "Стрекоза", "Скорпион", "Хамелеон", "Аллигатор", "Крокодил", "Вулкан",
            "Землетрясение", "Торнадо", "Ураган", "Галактика", "Планета", "Комета", "Астероид", "Вселенная", "Созвездие", "Пирамида",
            "Замок", "Дворец", "Храм", "Небоскреб", "Стадион", "Библиотека", "Музей", "Больница", "Университет", "Фабрика",
            "Ресторан", "Кинотеатр", "Театр", "Цирк", "Карнавал", "Фестиваль", "Отпуск", "Праздник", "День рождения", "Свадьба",
            "Годовщина", "Приключение", "Тайна", "Сокровище", "Пират", "Рыцарь", "Волшебник", "Дракон", "Единорог", "Феникс",
            "Ученый", "Художник", "Музыкант", "Актер", "Танцор", "Писатель", "Врач", "Учитель", "Инженер", "Повар",
            "Завтрак", "Обед", "Ужин", "Десерт", "Попкорн", "Пицца", "Бургер", "Суши", "Салат", "Сэндвич", "Радуга",
            "Тень", "Зеркало", "Эхо", "Сон", "Кошмар", "Сюрприз", "Секрет", "Пароль", "Пазл", "Загадка",
            "Чемпион", "Победа", "Поражение", "Успех", "Неудача", "Начало", "Середина", "Конец", "Путешествие", "Назначение",
            "Компас", "Карта", "Медаль", "Трофей", "Корона", "Трон", "Скипетр", "Щит", "Меч", "Стрела",
            // Added
            "Скутер", "Трамвай", "Троллейбус", "Дирижабль", "Катамаран", "Паром", "Танкер", "Ледокол", "Эскалатор", "Фуникулер",
            "Бинокль", "Перископ", "Стетоскоп", "Проектор", "Сканер", "Плоттер", "Наушники", "Микрофон", "Колонка", "Джойстик",
            "Флейта", "Арфа", "Виолончель", "Контрабас", "Кларнет", "Тромбон", "Волынка", "Орган", "Синтезатор", "Маракасы",
            "Носорог", "Бегемот", "Зебра", "Гепард", "Леопард", "Панда", "Коала", "Обезьяна", "Горилла", "Лемур",
            "Пеликан", "Фламинго", "Страус", "Павлин", "Орел", "Сокол", "Ястреб", "Сова", "Попугай", "Канарейка",
            "Акула", "Скат", "Мурена", "Медуза", "Краб", "Омар", "Креветка", "Кальмар", "Черепаха", "Игуана",
            "Кобра", "Гадюка", "Питон", "Тарантул", "Саранча", "Термит", "Муравей", "Оса", "Шмель", "Светлячок",
            "Гейзер", "Айсберг", "Ледник", "Водопад", "Каньон", "Ущелье", "Лавина", "Наводнение", "Засуха", "Цунами",
            "Метеор", "Спутник", "Орбита", "Туманность", "Квазар", "Пульсар", "Атмосфера", "Стратосфера", "Ионосфера", "Экзосфера",
            "Колизей", "Пантеон", "Акведук", "Мавзолей", "Крепость", "Цитадель", "Бункер", "Катакомбы", "Лабиринт", "Амфитеатр",
            "Обсерватория", "Планетарий", "Лаборатория", "Типография", "Консерватория", "Филармония", "Галерея", "Вернисаж", "Аукцион", "Ломбард",
            "Экспедиция", "Паломничество", "Круиз", "Сафари", "Экскурсия", "Марафон", "Олимпиада", "Чемпионат", "Турнир", "Регата",
            "Юбилей", "Новоселье", "Выпускной", "Маскарад", "Ярмарка", "Выставка", "Конференция", "Симпозиум", "Семинар", "Тренинг",
            "Детектив", "Шпион", "Агент", "Герой", "Злодей", "Предатель", "Союзник", "Монстр", "Призрак", "Вампир",
            "Оборотень", "Зомби", "Мумия", "Гном", "Эльф", "Орк", "Гоблин", "Тролль", "Циклоп", "Кентавр",
            "Русалка", "Сирена", "Гарпия", "Химера", "Минотавр", "Пегас", "Гиппогриф", "Василиск", "Мантикора", "Саламандра",
            "Профессор", "Академик", "Доцент", "Аспирант", "Студент", "Архитектор", "Конструктор", "Прораб", "Режиссер", "Сценарист",
            "Оператор", "Композитор", "Дирижер", "Хореограф", "Скульптор", "Ювелир", "Дизайнер", "Программист", "Администратор", "Аналитик",
            "Менеджер", "Директор", "Президент", "Министр", "Депутат", "Сенатор", "Губернатор", "Мэр", "Судья", "Адвокат",
            "Прокурор", "Нотариус", "Дипломат", "Посол", "Консул", "Атташе", "Фермер", "Шахтер", "Металлург", "Электрик",
            "Сантехник", "Плотник", "Столяр", "Сварщик", "Токарь", "Механик", "Водитель", "Пилот", "Капитан", "Космонавт",
            "Астронавт", "Журналист", "Репортер", "Корреспондент", "Фотограф", "Переводчик", "Гид", "Экскурсовод", "Тренер", "Спортсмен",
            "Арбитр", "Рефери", "Комментатор", "Аниматор", "Клоун", "Фокусник", "Акробат", "Жонглер", "Дрессировщик", "Каскадер",
            "Лазанья", "Паста", "Ризотто", "Стэйк", "Гуляш", "Круассан", "Багет", "Фондю", "Паэлья", "Такос",
            "Бутерброд", "Омлет", "Блины", "Ватрушка", "Пончик", "Кекс", "Зефир", "Мармелад", "Шоколад", "Лимонад",
            "Мираж", "Иллюзия", "Галлюцинация", "Дежавю", "Интуиция", "Вдохновение", "Предчувствие", "Ностальгия", "Эйфория", "Азарт",
            "Интрига", "Дилемма", "Компромисс", "Конфликт", "Перемирие", "Капитуляция", "Альянс", "Коалиция", "Фракция", "Оппозиция",
            "Репутация", "Авторитет", "Престиж", "Привилегия", "Статус", "Иммунитет", "Алиби", "Улика", "Вердикт", "Приговор",
            "Традиция", "Обычай", "Ритуал", "Обряд", "Церемония", "Суеверие", "Предрассудок", "Реликвия", "Артефакт", "Талисман",
            "Амулет", "Гороскоп", "Пророчество", "Гадание", "Заклинание", "Эликсир", "Зелье", "Ингредиент", "Рецепт", "Формула",
            "Прогресс", "Регресс", "Эволюция", "Революция", "Реформа", "Кризис", "Катастрофа", "Апокалипсис", "Ренессанс", "Возрождение",
            "Цивилизация", "Империя", "Династия", "Республика", "Федерация", "Конфедерация", "Колония", "Метрополия", "Провинция", "Столица",
            "Континент", "Архипелаг", "Полуостров", "Материк", "Пролив", "Залив", "Лагуна", "Фьорд", "Дельта", "Оазис",
            "Экватор", "Меридиан", "Параллель", "Полюс", "Тропик", "Климат", "Муссон", "Пассат", "Циклон", "Антициклон",
            "Интеллект", "Мудрость", "Талант", "Гений", "Способность", "Навык", "Привычка", "Инстинкт", "Рефлекс", "Характер",
            "Темперамент", "Личность", "Индивид", "Общество", "Коллектив", "Поколение", "Эпоха", "Эра", "Тысячелетие", "Век"
        ]

        private static let russianHardWords = [
            // Original
            "Архитектура", "Философия", "Психология", "Социология", "Антропология", "Археология", "Астрономия", "Биология", "Химия", "Физика",
            "Геология", "Экология", "Генетика", "Метафизика", "Эпистемология", "Онтология", "Демократия", "Республика", "Монархия", "Анархия",
            "Капитализм", "Социализм", "Коммунизм", "Фашизм", "Бюрократия", "Дипломатия", "Законодательство", "Юриспруденция", "Суверенитет", "Конституция",
            "Фотосинтез", "Метаморфоза", "Симбиоз", "Эволюция", "Гравитация", "Относительность", "Квант", "Парадокс", "Энигма", "Дилемма",
            "Ностальгия", "Эмпатия", "Апатия", "Эйфория", "Меланхолия", "Серендипность", "Синхронность", "Сопоставление", "Какофония", "Красноречие",
            "Двусмысленность", "Утонченность", "Ирония", "Сатира", "Метафора", "Аллегория", "Символизм", "Абстракция", "Сюрреализм", "Импрессионизм",
            "Ренессанс", "Барокко", "Готика", "Неоклассицизм", "Модернизм", "Постмодернизм", "Сознание", "Подсознание", "Интуиция", "Воображение",
            "Прокрастинация", "Амбиция", "Настойчивость", "Устойчивость", "Целостность", "Смирение", "Щедрость", "Сострадание", "Мудрость", "Храбрость",
            "Алхимия", "Астрология", "Мифология", "Фольклор", "Легенда", "Пророчество", "Чудо", "Судьба", "Карма", "Нирвана",
            "Криптовалюта", "Блокчейн", "Алгоритм", "Эвристика", "Кибернетика", "Биотехнология", "Нанотехнология", "Геополитика", "Макроэкономика", "Микроэкономика",
            "Равновесие", "Катализатор", "Гипотеза", "Теорема", "Аксиома", "Следствие", "Парадигма", "Феномен", "Спектр", "Континуум", "Бесконечность",
            // Added
            "Лингвистика", "Семиотика", "Политология", "Теология", "Космология", "Палеонтология", "Энтомология", "Орнитология", "Ихтиология", "Гистология",
            "Цитология", "Эмбриология", "Вирусология", "Микология", "Бактериология", "Фармакология", "Токсикология", "Криминология", "Криптография", "Картография",
            "Океанография", "Сейсмология", "Вулканология", "Климатология", "Петрография", "Минералогия", "Стратиграфия", "Термодинамика", "Электродинамика", "Аэродинамика",
            "Гидродинамика", "Акустика", "Оптика", "Механика", "Статистика", "Вероятность", "Комбинаторика", "Топология", "Алгебра", "Геометрия",
            "Экзистенциализм", "Гедонизм", "Стоицизм", "Прагматизм", "Нигилизм", "Гуманизм", "Идеализм", "Материализм", "Рационализм", "Эмпиризм",
            "Детерминизм", "Фатализм", "Волюнтаризм", "Агностицизм", "Скептицизм", "Позитивизм", "Структурализм", "Феноменология", "Герменевтика", "Диалектика",
            "Тоталитаризм", "Авторитаризм", "Либерализм", "Консерватизм", "Национализм", "Глобализм", "Изоляционизм", "Милитаризм", "Пацифизм", "Феминизм",
            "Плюрализм", "Лоббизм", "Сепаратизм", "Федерализм", "Централизм", "Протекционизм", "Меркантилизм", "Кейнсианство", "Монетаризм", "Либертарианство",
            "Коррупция", "Олигархия", "Плутократия", "Технократия", "Меритократия", "Охлократия", "Теократия", "Импичмент", "Ратификация", "Денонсация",
            "Юрисдикция", "Экстрадиция", "Амнистия", "Прерогатива", "Легитимность", "Инаугурация", "Кодификация", "Регламент", "Прецедент", "Меморандум",
            "Гомеостаз", "Анабиоз", "Биоценоз", "Экосистема", "Биосфера", "Ноосфера", "Регенерация", "Адаптация", "Мутация", "Репликация",
            "Транскрипция", "Трансляция", "Фермент", "Гормон", "Витамин", "Антитело", "Вакцина", "Анестезия", "Реанимация", "Диагностика",
            "Сингулярность", "Энтропия", "Неопределенность", "Корреляция", "Дисперсия", "Резонанс", "Интерференция", "Дифракция", "Поляризация", "Индукция",
            "Амплитуда", "Частота", "Энергия", "Импульс", "Инерция", "Траектория", "Турбулентность", "Эмиссия", "Аннигиляция", "Коллапс",
            "Когнитивность", "Ассоциация", "Абстрагирование", "Концентрация", "Восприятие", "Ощущение", "Рефлексия", "Сублимация", "Проекция", "Интроспекция",
            "Фрустрация", "Амбивалентность", "Конформизм", "Нонконформизм", "Альтруизм", "Эгоцентризм", "Перфекционизм", "Харизма", "Архетип", "Пассионарность",
            "Риторика", "Дебаты", "Диспут", "Полемика", "Дискуссия", "Монолог", "Диалог", "Полилог", "Аллюзия", "Оксюморон",
            "Гипербола", "Литота", "Перифраз", "Эвфемизм", "Антитеза", "Градация", "Инверсия", "Анафора", "Эпифора", "Параллелизм",
            "Аллитерация", "Ассонанс", "Пародия", "Эпиграмма", "Ода", "Элегия", "Сонет", "Баллада", "Эпос", "Драматургия",
            "Экспрессионизм", "Кубизм", "Футуризм", "Дадаизм", "Минимализм", "Концептуализм", "Классицизм", "Романтизм", "Реализм", "Натурализм",
            "Авангард", "Андеграунд", "Эклектика", "Стилизация", "Композиция", "Перспектива", "Гармония", "Диссонанс", "Полифония", "Лейтмотив",
            "Квинтэссенция", "Апогей", "Кульминация", "Катарсис", "Апофеоз", "Панацея", "Дежавю", "Жамевю", "Прескевю", "Архаизм",
            "Неологизм", "Профессионализм", "Диалектизм", "Жаргонизм", "Эпоним", "Топоним", "Антропоним", "Псевдоним", "Омоним", "Пароним",
            "Синоним", "Антоним", "Гипоним", "Гипероним", "Фразеологизм", "Идиома", "Лексикология", "Фонетика", "Морфология", "Синтаксис",
            "Пунктуация", "Орфография", "Этимология", "Ономастика", "Диверсификация", "Конвергенция", "Интеграция", "Стагнация", "Рецессия", "Инфляция",
            "Девальвация", "Ревальвация", "Деноминация", "Приватизация", "Национализация", "Монополия", "Олигополия", "Демпинг", "Эмбарго", "Франшиза",
            "Аутентичность", "Идентичность", "Компетентность", "Эрудиция", "Когерентность", "Трансцендентность", "Имманентность", "Прерогатива", "Дискредитация", "Реабилитация",
            "Деконструкция", "Пастиш", "Симулякр", "Дискурс", "Нарратив", "Интерпретация", "Коннотация", "Деннотация", "Экзегетика", "Апологетика",
            "Эсхатология", "Сотериология", "Экклезиология", "Агиография", "Иконография", "Патристика", "Схоластика", "Манускрипт", "Палимпсест", "Артефакт",
            "Инсигнии", "Геральдика", "Нумизматика", "Сфрагистика", "Генеалогия", "Вексиллология", "Фалеристика", "Бонистика", "Палеография", "Эпиграфика"
        ]
}
